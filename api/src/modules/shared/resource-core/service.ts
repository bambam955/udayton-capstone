import { HttpError } from '../../../app/errors.js';
import type { AuthPrincipal } from '../../../app/types.js';
import { buildResourceSchemas } from './schema.js';
import type {
  ResourceDefinition,
  ResourceListResult,
  ResourceMutationResult,
  ResourceOperation,
  ResourceOperationAccess,
  ResourceRepository,
  ResourceSchemaSet
} from './types.js';

function operationAccess(
  definition: ResourceDefinition,
  operation: ResourceOperation
): ResourceDefinition['listAccess'] {
  if (operation === 'list') {
    return definition.listAccess;
  }

  if (operation === 'get') {
    return definition.getAccess;
  }

  if (operation === 'create') {
    return definition.createAccess;
  }

  if (operation === 'update') {
    return definition.updateAccess;
  }

  return definition.deleteAccess;
}

function writableColumns(
  definition: ResourceDefinition,
  access: ResourceOperationAccess,
  operation: 'create' | 'update'
): string[] {
  if (access.writeColumns) {
    return access.writeColumns;
  }

  return Object.entries(definition.fields)
    .filter(([, field]) => (operation === 'create' ? field.createable : field.updateable))
    .map(([column]) => column);
}

export class ResourceService {
  private readonly schemas = new Map<string, ResourceSchemaSet>();

  constructor(
    private readonly repository: ResourceRepository,
    private readonly definitions: ResourceDefinition[]
  ) {
    for (const definition of definitions) {
      this.schemas.set(definition.name, buildResourceSchemas(definition));
    }
  }

  private getSchemas(definition: ResourceDefinition): ResourceSchemaSet {
    const schemas = this.schemas.get(definition.name);

    if (!schemas) {
      throw new Error(`Missing resource schemas for ${definition.name}`);
    }

    return schemas;
  }

  private resolveAccess(
    definition: ResourceDefinition,
    operation: ResourceOperation,
    principal: AuthPrincipal
  ): ResourceOperationAccess {
    const access = operationAccess(definition, operation)?.[principal.role];

    if (!access) {
      throw new HttpError(403, 'FORBIDDEN', 'You do not have access to this resource.');
    }

    return access;
  }

  private normalizeMutationValues(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    operation: 'create' | 'update',
    rawValues: Record<string, unknown>,
    principal: AuthPrincipal
  ): Record<string, unknown> {
    const allowedColumns = new Set(writableColumns(definition, access, operation));
    const disallowedColumns = Object.keys(rawValues).filter(
      (column) => !allowedColumns.has(column)
    );

    if (disallowedColumns.length > 0) {
      throw new HttpError(403, 'FORBIDDEN', 'The request contains fields you cannot modify.');
    }

    const values = { ...rawValues };

    if (access.injectPrincipalColumn) {
      values[access.injectPrincipalColumn] = principal.userId;
    }

    if (access.scope?.kind === 'direct' && !access.injectPrincipalColumn) {
      const ownerValue = values[access.scope.column];
      if (ownerValue !== undefined && ownerValue !== principal.userId) {
        throw new HttpError(403, 'FORBIDDEN', 'You do not have access to write that record.');
      }
    }

    const now = new Date();
    if (operation === 'create') {
      if ('created_at' in definition.fields && values.created_at === undefined) {
        values.created_at = now;
      }

      if ('updated_at' in definition.fields && values.updated_at === undefined) {
        values.updated_at = now;
      }
    }

    if (operation === 'update' && 'updated_at' in definition.fields) {
      values.updated_at = now;
    }

    return values;
  }

  async list(
    definition: ResourceDefinition,
    principal: AuthPrincipal,
    rawQuery: unknown
  ): Promise<ResourceListResult> {
    const access = this.resolveAccess(definition, 'list', principal);
    const parsed = this.getSchemas(definition).list.safeParse(rawQuery);

    if (!parsed.success) {
      throw new HttpError(
        400,
        'INVALID_REQUEST',
        parsed.error.issues[0]?.message ?? 'Invalid query parameters.'
      );
    }

    const input = {
      ...parsed.data,
      limit: Math.min(Math.max(parsed.data.limit, 1), 100)
    };
    const data = await this.repository.list(definition, access, principal, input);

    return { data };
  }

  async get(
    definition: ResourceDefinition,
    principal: AuthPrincipal,
    id: string
  ): Promise<ResourceMutationResult> {
    const access = this.resolveAccess(definition, 'get', principal);
    const data = await this.repository.get(definition, access, principal, id);

    if (!data) {
      throw new HttpError(404, 'NOT_FOUND', 'Resource not found.');
    }

    return { data };
  }

  async create(
    definition: ResourceDefinition,
    principal: AuthPrincipal,
    rawBody: unknown
  ): Promise<ResourceMutationResult> {
    const access = this.resolveAccess(definition, 'create', principal);
    const parsed = this.getSchemas(definition).create.safeParse(rawBody);

    if (!parsed.success) {
      throw new HttpError(
        400,
        'INVALID_REQUEST',
        parsed.error.issues[0]?.message ?? 'Invalid payload.'
      );
    }

    const values = this.normalizeMutationValues(
      definition,
      access,
      'create',
      parsed.data,
      principal
    );
    const allowed = await this.repository.canCreate(definition, access, principal, values);

    if (!allowed) {
      throw new HttpError(403, 'FORBIDDEN', 'You do not have access to create that record.');
    }

    const data = await this.repository.create(definition, access, principal, values);
    return { data };
  }

  async update(
    definition: ResourceDefinition,
    principal: AuthPrincipal,
    id: string,
    rawBody: unknown
  ): Promise<ResourceMutationResult> {
    const access = this.resolveAccess(definition, 'update', principal);
    const parsed = this.getSchemas(definition).update.safeParse(rawBody);

    if (!parsed.success) {
      throw new HttpError(
        400,
        'INVALID_REQUEST',
        parsed.error.issues[0]?.message ?? 'Invalid payload.'
      );
    }

    if (Object.keys(parsed.data).length === 0) {
      throw new HttpError(400, 'INVALID_REQUEST', 'At least one field must be provided.');
    }

    const values = this.normalizeMutationValues(
      definition,
      access,
      'update',
      parsed.data,
      principal
    );
    const data = await this.repository.update(definition, access, principal, id, values);

    if (!data) {
      throw new HttpError(404, 'NOT_FOUND', 'Resource not found.');
    }

    return { data };
  }

  async delete(
    definition: ResourceDefinition,
    principal: AuthPrincipal,
    id: string
  ): Promise<void> {
    const access = this.resolveAccess(definition, 'delete', principal);
    const deleted = await this.repository.delete(definition, access, principal, id);

    if (!deleted) {
      throw new HttpError(404, 'NOT_FOUND', 'Resource not found.');
    }
  }
}
