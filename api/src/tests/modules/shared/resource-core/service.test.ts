import { describe, expect, it, vi } from 'vitest';

import { HttpError } from '../../../../app/errors.js';
import { allResourceDefinitions } from '../../../../modules/shared/resource-core/all-definitions.js';
import { ResourceService } from '../../../../modules/shared/resource-core/service.js';
import type { ResourceRepository } from '../../../../modules/shared/resource-core/types.js';

function definition(path: string) {
  const resource = allResourceDefinitions.find((entry) => entry.path === path);

  if (!resource) {
    throw new Error(`Missing resource definition for ${path}`);
  }

  return resource;
}

function makeRepository(): ResourceRepository {
  return {
    canCreate: vi.fn().mockResolvedValue(true),
    list: vi.fn().mockResolvedValue([]),
    get: vi.fn().mockResolvedValue({}),
    create: vi.fn().mockResolvedValue({}),
    update: vi.fn().mockResolvedValue({}),
    delete: vi.fn().mockResolvedValue(true)
  };
}

describe('ResourceService', () => {
  it('injects the authenticated customer_id when creating an address', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await service.create(
      definition('addresses'),
      { userId: 'cust-1', role: 'customer', sessionId: 's1' },
      {
        label: 'HQ',
        line1: '123 Main St'
      }
    );

    expect(repository.create).toHaveBeenCalledWith(
      expect.any(Object),
      expect.any(Object),
      expect.objectContaining({ userId: 'cust-1' }),
      expect.objectContaining({
        customer_id: 'cust-1',
        label: 'HQ',
        line1: '123 Main St'
      })
    );
  });

  it('rejects writes to protected retailer account token columns for customers', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await expect(
      service.update(
        definition('retailer-accounts'),
        { userId: 'cust-1', role: 'customer', sessionId: 's1' },
        'acct-1',
        { access_token: 'secret-token' }
      )
    ).rejects.toMatchObject({
      statusCode: 403,
      code: 'FORBIDDEN'
    } satisfies Partial<HttpError>);
  });

  it('blocks customers from admin-only session resources', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await expect(
      service.list(
        definition('customer-sessions'),
        {
          userId: 'cust-1',
          role: 'customer',
          sessionId: 's1'
        },
        {}
      )
    ).rejects.toMatchObject({
      statusCode: 403,
      code: 'FORBIDDEN'
    } satisfies Partial<HttpError>);
  });

  it('bounds list limits before hitting the repository', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await service.list(
      definition('orders'),
      { userId: 'admin-1', role: 'admin', sessionId: 's1' },
      { limit: 999 }
    );

    expect(repository.list).toHaveBeenCalledWith(
      expect.any(Object),
      expect.any(Object),
      expect.objectContaining({ role: 'admin' }),
      expect.objectContaining({ limit: 100 })
    );
  });

  it('requires at least one field on patch requests', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await expect(
      service.update(
        definition('driver-payouts'),
        { userId: 'admin-1', role: 'admin', sessionId: 's1' },
        'payout-1',
        {}
      )
    ).rejects.toMatchObject({
      statusCode: 400,
      code: 'INVALID_REQUEST'
    } satisfies Partial<HttpError>);
  });
});
