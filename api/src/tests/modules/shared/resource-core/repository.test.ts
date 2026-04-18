import { describe, expect, it, vi } from 'vitest';
import type { Pool } from 'pg';

import { HttpError } from '../../../../app/errors.js';
import { allResourceDefinitions } from '../../../../modules/shared/resource-core/all-definitions.js';
import { PgResourceRepository } from '../../../../modules/shared/resource-core/repository.js';

function definition(path: string) {
  const resource = allResourceDefinitions.find((entry) => entry.path === path);

  if (!resource) {
    throw new Error(`Missing resource definition for ${path}`);
  }

  return resource;
}

describe('PgResourceRepository', () => {
  it('maps address delete foreign key conflicts to a controlled 409 error', async () => {
    const pool = {
      query: vi.fn().mockRejectedValue({ code: '23503' })
    };
    const repository = new PgResourceRepository(pool as unknown as Pool);

    await expect(
      repository.delete(
        definition('addresses'),
        {
          scope: {
            kind: 'direct',
            column: 'customer_id'
          }
        },
        {
          userId: 'cust-1',
          role: 'customer',
          sessionId: 'session-1'
        },
        'addr-1'
      )
    ).rejects.toMatchObject({
      statusCode: 409,
      code: 'CONFLICT',
      message: 'Address is used by an existing order.'
    } satisfies Partial<HttpError>);
  });
});
