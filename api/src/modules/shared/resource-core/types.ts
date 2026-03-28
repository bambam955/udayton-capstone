import type { z } from 'zod';

import type { AuthPrincipal } from '../../../app/types.js';
import type { AuthRole } from '../../../platform/auth/jwt.js';

export type ResourceOperation = 'list' | 'get' | 'create' | 'update' | 'delete';
export type ResourceFieldKind = 'string' | 'integer' | 'boolean' | 'timestamp' | 'date' | 'decimal';

export interface ResourceFieldDefinition {
  kind: ResourceFieldKind;
  readable?: boolean;
  filterable?: boolean;
  createable?: boolean;
  updateable?: boolean;
  requiredOnCreate?: boolean;
}

export interface ResourceOrderBy {
  column: string;
  direction: 'asc' | 'desc';
}

export interface DirectScopeRule {
  kind: 'direct';
  column: string;
}

export interface RelatedScopeRule {
  kind: 'related';
  table: string;
  localColumn: string;
  relatedColumn: string;
  ownerColumn: string;
}

export type ResourceScopeRule = DirectScopeRule | RelatedScopeRule;

export interface ResourceOperationAccess {
  scope?: ResourceScopeRule;
  writeColumns?: string[];
  injectPrincipalColumn?: string;
}

export interface ResourceDefinition {
  name: string;
  path: string;
  table: string;
  idColumn: string;
  fields: Record<string, ResourceFieldDefinition>;
  defaultOrderBy: ResourceOrderBy[];
  listAccess?: Partial<Record<AuthRole, ResourceOperationAccess>>;
  getAccess?: Partial<Record<AuthRole, ResourceOperationAccess>>;
  createAccess?: Partial<Record<AuthRole, ResourceOperationAccess>>;
  updateAccess?: Partial<Record<AuthRole, ResourceOperationAccess>>;
  deleteAccess?: Partial<Record<AuthRole, ResourceOperationAccess>>;
}

export interface ResourceListInput {
  limit: number;
  filters: Record<string, string | number | boolean>;
}

export interface ResourceListResult {
  data: Record<string, unknown>[];
}

export interface ResourceMutationResult {
  data: Record<string, unknown>;
}

export interface ResourceRepository {
  canCreate(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    values: Record<string, unknown>
  ): Promise<boolean>;
  list(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    input: ResourceListInput
  ): Promise<Record<string, unknown>[]>;
  get(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    id: string
  ): Promise<Record<string, unknown> | null>;
  create(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    values: Record<string, unknown>
  ): Promise<Record<string, unknown>>;
  update(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    id: string,
    values: Record<string, unknown>
  ): Promise<Record<string, unknown> | null>;
  delete(
    definition: ResourceDefinition,
    access: ResourceOperationAccess,
    principal: AuthPrincipal,
    id: string
  ): Promise<boolean>;
}

export interface ResourceSchemaSet {
  list: z.ZodType<ResourceListInput>;
  create: z.ZodType<Record<string, unknown>>;
  update: z.ZodType<Record<string, unknown>>;
}
