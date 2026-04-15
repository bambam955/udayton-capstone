import { describe, expect, it, vi } from 'vitest';

import { MobileService } from '../../../modules/mobile/service.js';
import type { MobileRepository } from '../../../modules/mobile/types.js';

function makeRepository(): MobileRepository {
  return {
    getCustomerBootstrap: vi.fn().mockResolvedValue({}),
    getCustomerCatalog: vi.fn().mockResolvedValue({}),
    setRetailerConnection: vi.fn().mockResolvedValue({}),
    cancelOrder: vi.fn().mockResolvedValue({}),
    checkout: vi.fn().mockResolvedValue({}),
    getDriverBootstrap: vi.fn().mockResolvedValue({}),
    acceptDelivery: vi.fn().mockResolvedValue({}),
    pickupDelivery: vi.fn().mockResolvedValue({}),
    completeDelivery: vi.fn().mockResolvedValue({})
  } as unknown as MobileRepository;
}

function customerPrincipal() {
  return {
    userId: 'cust-1',
    role: 'customer' as const,
    sessionId: 'session-customer-1'
  };
}

function driverPrincipal() {
  return {
    userId: 'driver-1',
    role: 'driver' as const,
    sessionId: 'session-driver-1'
  };
}

function adminPrincipal() {
  return {
    userId: 'admin-1',
    role: 'admin' as const,
    sessionId: 'session-admin-1'
  };
}

describe('mobile service', () => {
  it('rejects driver principals from customer bootstrap', async () => {
    const service = new MobileService(makeRepository());

    await expect(service.getCustomerBootstrap(driverPrincipal())).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
  });

  it('forwards customer catalog requests to the repository', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);

    await service.getCustomerCatalog(customerPrincipal(), {
      retailerLocationId: '11111111-1111-1111-1111-111111111111',
      category: 'Pantry',
      query: 'soap'
    });

    expect(repository.getCustomerCatalog).toHaveBeenCalledWith('cust-1', {
      retailerLocationId: '11111111-1111-1111-1111-111111111111',
      category: 'Pantry',
      query: 'soap'
    });
  });

  it('forwards connect and disconnect actions with the expected flag', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);
    const principal = customerPrincipal();

    await service.connectRetailer(principal, 'ret-1');
    await service.disconnectRetailer(principal, 'ret-1');

    expect(repository.setRetailerConnection).toHaveBeenNthCalledWith(1, 'cust-1', 'ret-1', true);
    expect(repository.setRetailerConnection).toHaveBeenNthCalledWith(2, 'cust-1', 'ret-1', false);
  });

  it('forwards customer checkout requests to the repository', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);

    await service.checkout(customerPrincipal(), {
      cartId: '11111111-1111-4111-8111-111111111111',
      addressId: '22222222-2222-4222-8222-222222222222',
      deliveryNotes: 'Leave with concierge',
      tipCents: 750
    });

    expect(repository.checkout).toHaveBeenCalledWith('cust-1', {
      cartId: '11111111-1111-4111-8111-111111111111',
      addressId: '22222222-2222-4222-8222-222222222222',
      deliveryNotes: 'Leave with concierge',
      tipCents: 750
    });
  });

  it('forwards customer cancel requests to the repository', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);

    await service.cancelOrder(customerPrincipal(), 'order-1');

    expect(repository.cancelOrder).toHaveBeenCalledWith('cust-1', 'order-1');
  });

  it('rejects driver principals from customer-only actions', async () => {
    const service = new MobileService(makeRepository());

    await expect(service.connectRetailer(driverPrincipal(), 'ret-1')).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
    await expect(service.disconnectRetailer(driverPrincipal(), 'ret-1')).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
    await expect(
      service.checkout(driverPrincipal(), {
        cartId: '11111111-1111-4111-8111-111111111111',
        addressId: '22222222-2222-4222-8222-222222222222'
      })
    ).rejects.toMatchObject({ code: 'FORBIDDEN' });
    await expect(service.cancelOrder(driverPrincipal(), 'order-1')).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
    await expect(service.cancelOrder(adminPrincipal(), 'order-1')).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
  });

  it('forwards driver bootstrap and delivery actions to the repository', async () => {
    const repository = makeRepository();
    const service = new MobileService(repository);

    await service.getDriverBootstrap(driverPrincipal());
    await service.acceptDelivery(driverPrincipal(), 'delivery-1');
    await service.pickupDelivery(driverPrincipal(), 'delivery-1');
    await service.completeDelivery(driverPrincipal(), 'delivery-1');

    expect(repository.getDriverBootstrap).toHaveBeenCalledWith('driver-1');
    expect(repository.acceptDelivery).toHaveBeenCalledWith('driver-1', 'delivery-1');
    expect(repository.pickupDelivery).toHaveBeenCalledWith('driver-1', 'delivery-1');
    expect(repository.completeDelivery).toHaveBeenCalledWith('driver-1', 'delivery-1');
  });

  it('rejects customer principals from driver-only actions', async () => {
    const service = new MobileService(makeRepository());

    await expect(service.getDriverBootstrap(customerPrincipal())).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
    await expect(service.acceptDelivery(customerPrincipal(), 'delivery-1')).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
    await expect(service.pickupDelivery(customerPrincipal(), 'delivery-1')).rejects.toMatchObject({
      code: 'FORBIDDEN'
    });
    await expect(service.completeDelivery(customerPrincipal(), 'delivery-1')).rejects.toMatchObject(
      {
        code: 'FORBIDDEN'
      }
    );
  });
});
