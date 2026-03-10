import { describe, expect, it, vi } from 'vitest';

import { HttpError } from '../../../app/errors.js';
import type { OrdersRepository } from '../../../modules/orders/repository.js';
import { OrdersService } from '../../../modules/orders/service.js';

function makeRepo(): OrdersRepository {
  return {
    listByCustomer: vi.fn().mockResolvedValue([]),
    listRecent: vi.fn().mockResolvedValue([])
  };
}

describe('OrdersService', () => {
  it('limits and returns customer orders', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await service.listOrders(
      { userId: 'cust-1', role: 'customer', sessionId: 's1' },
      { limit: 999 }
    );

    expect(repo.listByCustomer).toHaveBeenCalledWith('cust-1', 100);
  });

  it('blocks customers from requesting another customerId', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await expect(
      service.listOrders(
        { userId: 'cust-1', role: 'customer', sessionId: 's1' },
        { limit: 20, customerId: 'cust-2' }
      )
    ).rejects.toMatchObject({
      statusCode: 403,
      code: 'FORBIDDEN'
    } satisfies Partial<HttpError>);
  });

  it('allows admin to list all recent orders', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await service.listOrders({ userId: 'admin-1', role: 'admin', sessionId: 's1' }, { limit: 20 });

    expect(repo.listRecent).toHaveBeenCalledWith(20);
  });

  it('allows admin to filter by customerId', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await service.listOrders(
      { userId: 'admin-1', role: 'admin', sessionId: 's1' },
      { limit: 20, customerId: 'cust-9' }
    );

    expect(repo.listByCustomer).toHaveBeenCalledWith('cust-9', 20);
  });

  it('blocks unsupported roles', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await expect(
      service.listOrders({ userId: 'driver-1', role: 'driver', sessionId: 's1' }, { limit: 20 })
    ).rejects.toMatchObject({
      statusCode: 403,
      code: 'FORBIDDEN'
    } satisfies Partial<HttpError>);
  });
});
