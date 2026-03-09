import { describe, expect, it, vi } from 'vitest';

import { HttpError } from '../../app/errors.js';
import { OrdersService } from './service.js';
import type { OrdersRepository } from './repository.js';

function makeRepo(): OrdersRepository {
  return {
    listByCustomer: vi.fn().mockResolvedValue([])
  };
}

describe('OrdersService', () => {
  it('limits and returns customer orders', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await service.listMyOrders({ userId: 'cust-1', role: 'customer', sessionId: 's1' }, 999);

    expect(repo.listByCustomer).toHaveBeenCalledWith('cust-1', 100);
  });

  it('blocks non-customer roles', async () => {
    const repo = makeRepo();
    const service = new OrdersService(repo);

    await expect(
      service.listMyOrders({ userId: 'driver-1', role: 'driver', sessionId: 's1' }, 20)
    ).rejects.toMatchObject<HttpError>({
      statusCode: 403,
      code: 'FORBIDDEN'
    });
  });
});
