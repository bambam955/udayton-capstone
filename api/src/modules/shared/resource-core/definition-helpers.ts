import type { AuthRole } from '../../../platform/auth/jwt.js';

import type { ResourceDefinition, ResourceFieldDefinition, ResourceOperationAccess } from './types.js';

export function stringField(
  overrides: Partial<ResourceFieldDefinition> = {}
): ResourceFieldDefinition {
  return {
    kind: 'string',
    readable: true,
    ...overrides
  };
}

export function integerField(
  overrides: Partial<ResourceFieldDefinition> = {}
): ResourceFieldDefinition {
  return {
    kind: 'integer',
    readable: true,
    ...overrides
  };
}

export function booleanField(
  overrides: Partial<ResourceFieldDefinition> = {}
): ResourceFieldDefinition {
  return {
    kind: 'boolean',
    readable: true,
    ...overrides
  };
}

export function timestampField(
  overrides: Partial<ResourceFieldDefinition> = {}
): ResourceFieldDefinition {
  return {
    kind: 'timestamp',
    readable: true,
    ...overrides
  };
}

export function decimalField(
  overrides: Partial<ResourceFieldDefinition> = {}
): ResourceFieldDefinition {
  return {
    kind: 'decimal',
    readable: true,
    ...overrides
  };
}

export function adminOnly(): Partial<Record<AuthRole, ResourceOperationAccess>> {
  return {
    admin: {}
  };
}

export function resource(definition: Omit<ResourceDefinition, 'defaultOrderBy'>): ResourceDefinition {
  return {
    ...definition,
    defaultOrderBy: defaultOrderBy(definition.fields, definition.idColumn)
  };
}

function defaultOrderBy(fields: Record<string, ResourceFieldDefinition>, idColumn: string) {
  if ('created_at' in fields) {
    return [{ column: 'created_at', direction: 'desc' as const }];
  }

  if ('updated_at' in fields) {
    return [{ column: 'updated_at', direction: 'desc' as const }];
  }

  return [{ column: idColumn, direction: 'asc' as const }];
}
