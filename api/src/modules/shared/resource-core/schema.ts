import { z } from 'zod';

import type {
  ResourceDefinition,
  ResourceFieldDefinition,
  ResourceListInput,
  ResourceOperationAccess,
  ResourceSchemaSet
} from './types.js';

function fieldValueSchema(field: ResourceFieldDefinition) {
  if (field.kind === 'integer' || field.kind === 'decimal') {
    return z.union([z.coerce.number(), z.null()]);
  }

  if (field.kind === 'boolean') {
    return z.union([
      z.boolean(),
      z.string().transform((value, ctx) => {
        if (value === 'true') {
          return true;
        }

        if (value === 'false') {
          return false;
        }

        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: 'Expected boolean.'
        });

        return z.NEVER;
      }),
      z.null()
    ]);
  }

  if (field.kind === 'timestamp' || field.kind === 'date') {
    return z.union([z.string().min(1), z.null()]);
  }

  return z.union([z.string().min(1), z.null()]);
}

function listFilterSchema(field: ResourceFieldDefinition) {
  if (field.kind === 'integer' || field.kind === 'decimal') {
    return z.coerce.number();
  }

  if (field.kind === 'boolean') {
    return z.string().transform((value, ctx) => {
      if (value === 'true') {
        return true;
      }

      if (value === 'false') {
        return false;
      }

      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Expected boolean.'
      });

      return z.NEVER;
    });
  }

  return z.string().min(1);
}

function writableCreateColumns(
  definition: ResourceDefinition,
  access: ResourceOperationAccess
): Set<string> {
  if (access.writeColumns) {
    return new Set(access.writeColumns);
  }

  return new Set(
    Object.entries(definition.fields)
      .filter(([, field]) => field.createable)
      .map(([column]) => column)
  );
}

export function buildResourceCreateSchema(
  definition: ResourceDefinition,
  access: ResourceOperationAccess
): z.ZodType<Record<string, unknown>> {
  const createShape: Record<string, z.ZodTypeAny> = {};
  const writableColumns = writableCreateColumns(definition, access);

  for (const [column, field] of Object.entries(definition.fields)) {
    if (!field.createable) {
      continue;
    }

    const requiredFromRequest =
      field.requiredOnCreate === true &&
      writableColumns.has(column) &&
      access.injectPrincipalColumn !== column;

    createShape[column] = requiredFromRequest
      ? fieldValueSchema(field)
      : fieldValueSchema(field).optional();
  }

  return z.object(createShape).strict();
}

export function buildResourceSchemas(definition: ResourceDefinition): ResourceSchemaSet {
  const listShape: Record<string, z.ZodTypeAny> = {
    limit: z.coerce.number().int().positive().default(20),
    offset: z.coerce.number().int().nonnegative().default(0)
  };
  const createShape: Record<string, z.ZodTypeAny> = {};
  const updateShape: Record<string, z.ZodTypeAny> = {};

  for (const [column, field] of Object.entries(definition.fields)) {
    if (field.filterable) {
      listShape[column] = listFilterSchema(field).optional();
    }

    if (field.createable) {
      createShape[column] = fieldValueSchema(field).optional();
    }

    if (field.updateable) {
      updateShape[column] = fieldValueSchema(field).optional();
    }
  }

  const list = z
    .object(listShape)
    .strict()
    .transform((value): ResourceListInput => {
      const { limit, offset, ...rest } = value;
      const filters = Object.fromEntries(
        Object.entries(rest).filter(([, entry]) => entry !== undefined)
      ) as Record<string, string | number | boolean>;

      return {
        limit: Number(limit),
        offset: Number(offset),
        filters
      };
    });

  const create = z.object(createShape).strict();
  const update = z.object(updateShape).strict();

  return {
    list,
    create,
    update
  };
}
