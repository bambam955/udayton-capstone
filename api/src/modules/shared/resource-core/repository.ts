import type { Pool } from 'pg';

import type { AuthPrincipal } from '../../../app/types.js';
import type {
  ResourceDefinition,
  ResourceListInput,
  ResourceOperationAccess,
  ResourceRepository
} from './types.js';

function quoteIdentifier(identifier: string): string {
  if (!/^[a-z][a-z0-9_]*$/i.test(identifier)) {
    throw new Error(`Unsafe SQL identifier: ${identifier}`);
  }

  return `"${identifier}"`;
}

function readableColumns(definition: ResourceDefinition): string[] {
  return Object.entries(definition.fields)
    .filter(([, field]) => field.readable !== false)
    .map(([column]) => column);
}

function scopeClause(
  access: ResourceOperationAccess,
  principal: AuthPrincipal,
  baseAlias: string,
  params: unknown[]
): string | null {
  if (!access.scope) {
    return null;
  }

  if (access.scope.kind === 'direct') {
    params.push(principal.userId);
    return `${baseAlias}.${quoteIdentifier(access.scope.column)} = $${params.length}`;
  }

  params.push(principal.userId);

  return `exists (
    select 1
    from ${quoteIdentifier(access.scope.table)} as scope_rel
    where scope_rel.${quoteIdentifier(access.scope.relatedColumn)} = ${baseAlias}.${quoteIdentifier(access.scope.localColumn)}
      and scope_rel.${quoteIdentifier(access.scope.ownerColumn)} = $${params.length}
  )`;
}

function selectList(definition: ResourceDefinition, alias: string): string {
  return readableColumns(definition)
    .map((column) => `${alias}.${quoteIdentifier(column)}`)
    .join(', ');
}

export class PgResourceRepository implements ResourceRepository {
  constructor(private readonly pool: Pool) {}

  async canCreate(
    _definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    values: Record<string, unknown>
  ): Promise<boolean> {
    if (!access.scope) {
      return true;
    }

    if (access.scope.kind === 'direct') {
      const value = values[access.scope.column];
      return value === undefined || value === principal.userId;
    }

    const localValue = values[access.scope.localColumn];
    if (localValue === undefined || localValue === null) {
      // Some create-time ownership checks are conditional, such as support
      // tickets that may or may not reference an order.
      return true;
    }

    if (typeof localValue !== 'string' || localValue.length === 0) {
      return false;
    }

    const query = `
      select 1
      from ${quoteIdentifier(access.scope.table)} as scope_rel
      where scope_rel.${quoteIdentifier(access.scope.relatedColumn)} = $1
        and scope_rel.${quoteIdentifier(access.scope.ownerColumn)} = $2
      limit 1
    `;
    const result = await this.pool.query(query, [localValue, principal.userId]);

    return (result.rowCount ?? 0) > 0;
  }

  async list(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    input: ResourceListInput
  ): Promise<Record<string, unknown>[]> {
    const params: unknown[] = [];
    const whereClauses: string[] = [];

    const scopedWhere = scopeClause(access, principal, 'base', params);
    if (scopedWhere) {
      whereClauses.push(scopedWhere);
    }

    for (const [column, value] of Object.entries(input.filters)) {
      params.push(value);
      whereClauses.push(`base.${quoteIdentifier(column)} = $${params.length}`);
    }

    params.push(input.limit);
    const orderBy = definition.defaultOrderBy
      .map(({ column, direction }) => `base.${quoteIdentifier(column)} ${direction}`)
      .join(', ');
    const whereSql = whereClauses.length > 0 ? `where ${whereClauses.join(' and ')}` : '';
    const query = `
      select ${selectList(definition, 'base')}
      from ${quoteIdentifier(definition.table)} as base
      ${whereSql}
      order by ${orderBy}
      limit $${params.length}
    `;
    const result = await this.pool.query(query, params);

    return result.rows;
  }

  async get(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    id: string
  ): Promise<Record<string, unknown> | null> {
    const params: unknown[] = [id];
    const whereClauses = [`base.${quoteIdentifier(definition.idColumn)} = $1`];
    const scopedWhere = scopeClause(access, principal, 'base', params);

    if (scopedWhere) {
      whereClauses.push(scopedWhere);
    }

    const query = `
      select ${selectList(definition, 'base')}
      from ${quoteIdentifier(definition.table)} as base
      where ${whereClauses.join(' and ')}
      limit 1
    `;
    const result = await this.pool.query(query, params);

    return result.rows[0] ?? null;
  }

  async create(
    definition: ResourceDefinition,
    _access: ResourceOperationAccess,
    _principal: AuthPrincipal,
    values: Record<string, unknown>
  ): Promise<Record<string, unknown>> {
    const entries = Object.entries(values);
    const columns = entries.map(([column]) => quoteIdentifier(column));
    const placeholders = entries.map((_, index) => `$${index + 1}`);
    const params = entries.map(([, value]) => value);
    const valueSql =
      entries.length > 0
        ? `(${columns.join(', ')}) values (${placeholders.join(', ')})`
        : 'default values';
    const query = `
      insert into ${quoteIdentifier(definition.table)}
      ${valueSql}
      returning ${readableColumns(definition)
        .map((column) => quoteIdentifier(column))
        .join(', ')}
    `;
    const result = await this.pool.query(query, params);

    return result.rows[0] as Record<string, unknown>;
  }

  async update(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    id: string,
    values: Record<string, unknown>
  ): Promise<Record<string, unknown> | null> {
    const entries = Object.entries(values);
    if (entries.length === 0) {
      return this.get(definition, access, principal, id);
    }

    const params: unknown[] = [];
    const sets = entries.map(([column, value]) => {
      params.push(value);
      return `${quoteIdentifier(column)} = $${params.length}`;
    });

    params.push(id);
    const whereClauses = [`${quoteIdentifier(definition.idColumn)} = $${params.length}`];
    const scopedWhere = scopeClause(access, principal, quoteIdentifier(definition.table), params);

    if (scopedWhere) {
      whereClauses.push(scopedWhere);
    }

    const query = `
      update ${quoteIdentifier(definition.table)}
      set ${sets.join(', ')}
      where ${whereClauses.join(' and ')}
      returning ${readableColumns(definition)
        .map((column) => quoteIdentifier(column))
        .join(', ')}
    `;
    const result = await this.pool.query(query, params);

    return (result.rows[0] as Record<string, unknown> | undefined) ?? null;
  }

  async delete(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    id: string
  ): Promise<boolean> {
    const params: unknown[] = [id];
    const whereClauses = [`${quoteIdentifier(definition.idColumn)} = $1`];
    const scopedWhere = scopeClause(access, principal, quoteIdentifier(definition.table), params);

    if (scopedWhere) {
      whereClauses.push(scopedWhere);
    }

    const query = `
      delete from ${quoteIdentifier(definition.table)}
      where ${whereClauses.join(' and ')}
    `;
    const result = await this.pool.query(query, params);

    return (result.rowCount ?? 0) > 0;
  }
}
