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

  it('returns 404 when a requested record is missing', async () => {
    const repository = makeRepository();
    repository.get = vi.fn().mockResolvedValue(null);
    const service = new ResourceService(repository, allResourceDefinitions);

    await expect(
      service.get(definition('payments'), { userId: 'admin-1', role: 'admin', sessionId: 's1' }, 'pay-1')
    ).rejects.toMatchObject({
      statusCode: 404,
      code: 'NOT_FOUND'
    } satisfies Partial<HttpError>);
  });

  it('returns 403 when scoped creates fail the ownership check', async () => {
    const repository = makeRepository();
    repository.canCreate = vi.fn().mockResolvedValue(false);
    const service = new ResourceService(repository, allResourceDefinitions);

    await expect(
      service.create(
        definition('delivery-proof'),
        { userId: 'driver-1', role: 'driver', sessionId: 's1' },
        {
          delivery_id: 'delivery-1',
          proof_type: 'PHOTO'
        }
      )
    ).rejects.toMatchObject({
      statusCode: 403,
      code: 'FORBIDDEN'
    } satisfies Partial<HttpError>);
  });

  it('adds updated_at automatically on admin-managed resources during patches', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await service.update(
      definition('orders'),
      { userId: 'admin-1', role: 'admin', sessionId: 's1' },
      'order-1',
      { status: 'CAPTURED' }
    );

    expect(repository.update).toHaveBeenCalledWith(
      expect.any(Object),
      expect.any(Object),
      expect.objectContaining({ role: 'admin' }),
      'order-1',
      expect.objectContaining({
        status: 'CAPTURED'
      })
    );
    expect(vi.mocked(repository.update).mock.calls[0]?.[4]).toEqual(
      expect.objectContaining({
        updated_at: expect.any(Date)
      })
    );
  });

  it('rejects invalid list queries before hitting the repository', async () => {
    const repository = makeRepository();
    const service = new ResourceService(repository, allResourceDefinitions);

    await expect(
      service.list(
        definition('products'),
        { userId: 'admin-1', role: 'admin', sessionId: 's1' },
        { is_available: 'sometimes' }
      )
    ).rejects.toMatchObject({
      statusCode: 400,
      code: 'INVALID_REQUEST'
    } satisfies Partial<HttpError>);
    expect(repository.list).not.toHaveBeenCalled();
  });
});
