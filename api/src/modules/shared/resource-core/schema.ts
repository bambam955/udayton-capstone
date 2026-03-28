import { z } from 'zod';

import type {
  ResourceDefinition,
  ResourceFieldDefinition,
  ResourceListInput,
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

export function buildResourceSchemas(definition: ResourceDefinition): ResourceSchemaSet {
  const listShape: Record<string, z.ZodTypeAny> = {
    limit: z.coerce.number().int().positive().default(20)
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
      const { limit, ...rest } = value;
      const filters = Object.fromEntries(
        Object.entries(rest).filter(([, entry]) => entry !== undefined)
      ) as Record<string, string | number | boolean>;

      return {
        limit: Number(limit),
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
