import { describe, expect, it, vi } from 'vitest';

import { MobileService } from '../../../modules/mobile/service.js';
import type { MobileRepository } from '../../../modules/mobile/types.js';

function makeRepository(): MobileRepository {
  return {
    getCustomerBootstrap: vi.fn().mockResolvedValue({}),
    getCustomerCatalog: vi.fn().mockResolvedValue({}),
    setRetailerConnection: vi.fn().mockResolvedValue({}),
    checkout: vi.fn().mockResolvedValue({}),
    getDriverBootstrap: vi.fn().mockResolvedValue({}),
    acceptDelivery: vi.fn().mockResolvedValue({}),
    pickupDelivery: vi.fn().mockResolvedValue({}),
    completeDelivery: vi.fn().mockResolvedValue({})
  } as unknown as MobileRepository;
}

describe('mobile service', () => {
  it('rejects driver principals from customer bootstrap', async () => {
    const service = new MobileService(makeRepository());

    await expect(
      service.getCustomerBootstrap({
        userId: 'driver-1',
        role: 'driver',
        sessionId: 'session-1'
      })
    ).rejects.toMatchObject({ code: 'FORBIDDEN' });
  });

  it('forwards customer catalog requests to the repository', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);

    await service.getCustomerCatalog(
      {
        userId: 'cust-1',
        role: 'customer',
        sessionId: 'session-1'
      },
      {
        retailerLocationId: '11111111-1111-1111-1111-111111111111',
        category: 'Pantry',
        query: 'soap'
      }
    );

    expect(repository.getCustomerCatalog).toHaveBeenCalledWith('cust-1', {
      retailerLocationId: '11111111-1111-1111-1111-111111111111',
      category: 'Pantry',
      query: 'soap'
    });
  });

  it('forwards connect and disconnect actions with the expected flag', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);
    const principal = {
      userId: 'cust-1',
      role: 'customer' as const,
      sessionId: 'session-1'
    };

    await service.connectRetailer(principal, 'ret-1');
    await service.disconnectRetailer(principal, 'ret-1');

    expect(repository.setRetailerConnection).toHaveBeenNthCalledWith(1, 'cust-1', 'ret-1', true);
    expect(repository.setRetailerConnection).toHaveBeenNthCalledWith(2, 'cust-1', 'ret-1', false);
  });

  it('rejects customer principals from driver delivery actions', async () => {
    const service = new MobileService(makeRepository());

    await expect(
      service.acceptDelivery(
        {
          userId: 'cust-1',
          role: 'customer',
          sessionId: 'session-1'
        },
        'delivery-1'
      )
    ).rejects.toMatchObject({ code: 'FORBIDDEN' });
  });
});
