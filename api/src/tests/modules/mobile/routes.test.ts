import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { createApp } from '../../../app/createApp.js';
import { HttpError } from '../../../app/errors.js';
import { MobileService } from '../../../modules/mobile/service.js';
import type { MobileRepository, MobileServiceContract } from '../../../modules/mobile/types.js';
import { makeBearer } from '../../support/resource-test-helpers.js';

function makeMobileService() {
  return {
    getCustomerBootstrap: vi.fn().mockResolvedValue({
      customer: { id: 'cust-1', email: 'customer@example.com', fullName: 'Customer Example' },
      retailers: [],
      addresses: [],
      carts: [],
      orders: [],
      supportTickets: [],
      defaultAddressId: null
    }),
    getCustomerCatalog: vi.fn().mockResolvedValue({
      location: {
        retailerLocationId: '11111111-1111-1111-1111-111111111111',
        retailerId: 'ret-1',
        externalStoreId: null,
        name: 'FreshMart Downtown',
        addressLine: '10 Main St',
        city: 'Dayton',
        state: 'OH',
        postalCode: '45402',
        country: 'USA',
        lat: 39.75,
        lng: -84.19,
        isActive: true
      },
      retailer: { retailerId: 'ret-1', name: 'FreshMart' },
      categories: [],
      products: [],
      cart: null
    }),
    connectRetailer: vi.fn().mockResolvedValue({
      retailerId: 'ret-1',
      isConnected: true,
      connectedAt: '2026-03-30T12:00:00.000Z'
    }),
    disconnectRetailer: vi.fn().mockResolvedValue({
      retailerId: 'ret-1',
      isConnected: false,
      connectedAt: '2026-03-30T12:00:00.000Z'
    }),
    cancelOrder: vi.fn().mockResolvedValue({
      orderId: 'order-1',
      externalOrderId: 'ORD-10001',
      retailerId: 'ret-1',
      retailerName: 'FreshMart',
      retailerLocationId: 'loc-1',
      retailerLocationName: 'FreshMart Downtown',
      status: 'CANCELED',
      placedAt: '2026-03-30T12:00:00.000Z',
      totalCents: 4599,
      currency: 'USD',
      itemCount: 3
    }),
    checkout: vi.fn().mockResolvedValue({
      order: {
        orderId: 'order-1',
        externalOrderId: 'ORD-10001',
        retailerId: 'ret-1',
        retailerName: 'FreshMart',
        retailerLocationId: 'loc-1',
        retailerLocationName: 'FreshMart Downtown',
        status: 'SUBMITTED',
        placedAt: '2026-03-30T12:00:00.000Z',
        totalCents: 4599,
        currency: 'USD',
        itemCount: 3
      },
      pricing: {
        subtotalCents: 3000,
        serviceFeeCents: 199,
        deliveryFeeCents: 499,
        estimatedTaxCents: 151,
        tipCents: 750,
        totalCents: 4599,
        currency: 'USD'
      },
      payment: {
        paymentId: 'payment-1',
        status: 'AUTHORIZED',
        amountCents: 4599,
        currency: 'USD'
      },
      delivery: {
        deliveryId: 'delivery-1',
        status: 'PENDING_ASSIGNMENT',
        pickupLocation: 'FreshMart Downtown'
      }
    }),
    getDriverBootstrap: vi.fn().mockResolvedValue({
      driver: {
        id: 'driver-1',
        email: 'driver@example.com',
        fullName: 'Driver Example',
        status: 'ONLINE'
      },
      availableJobs: [],
      activeJobs: [],
      completedJobs: [],
      supportTickets: [],
      earningsSummary: {
        todayGrossCents: 0,
        tipsCents: 0,
        bonusCents: 0,
        nextPayoutLabel: 'Tomorrow 9:00 AM'
      }
    }),
    acceptDelivery: vi.fn().mockResolvedValue({ deliveryId: 'delivery-1', stage: 'assigned' }),
    pickupDelivery: vi
      .fn()
      .mockResolvedValue({ deliveryId: 'delivery-1', stage: 'out_for_delivery' }),
    completeDelivery: vi.fn().mockResolvedValue({ deliveryId: 'delivery-1', stage: 'delivered' })
  };
}

function makeApp(mobileService: MobileServiceContract = makeMobileService() as never) {
  return createApp({
    authService: {
      signup: async () => undefined,
      login: async () => undefined,
      logout: async () => undefined,
      isSessionActive: async () => true
    } as never,
    resourceService: {
      list: async () => ({ data: [] }),
      get: async () => ({ data: {} }),
      create: async () => ({ data: {} }),
      update: async () => ({ data: {} }),
      delete: async () => undefined
    } as never,
    mobileService: mobileService as never
  });
}

function makeRepository(): MobileRepository {
  return {
    getCustomerBootstrap: vi.fn().mockResolvedValue({
      customer: { id: 'cust-1', email: 'customer@example.com', fullName: 'Customer Example' },
      retailers: [],
      addresses: [],
      carts: [],
      orders: [],
      supportTickets: [],
      defaultAddressId: null
    }),
    getCustomerCatalog: vi.fn().mockResolvedValue({
      location: {
        retailerLocationId: '11111111-1111-1111-1111-111111111111',
        retailerId: 'ret-1',
        externalStoreId: null,
        name: 'FreshMart Downtown',
        addressLine: '10 Main St',
        city: 'Dayton',
        state: 'OH',
        postalCode: '45402',
        country: 'USA',
        lat: 39.75,
        lng: -84.19,
        isActive: true
      },
      retailer: { retailerId: 'ret-1', name: 'FreshMart' },
      categories: [],
      products: [],
      cart: null
    }),
    setRetailerConnection: vi.fn().mockResolvedValue({
      retailerId: 'ret-1',
      isConnected: true,
      connectedAt: '2026-03-30T12:00:00.000Z'
    }),
    cancelOrder: vi.fn().mockResolvedValue({
      orderId: 'order-1',
      externalOrderId: 'ORD-10001',
      retailerId: 'ret-1',
      retailerName: 'FreshMart',
      retailerLocationId: 'loc-1',
      retailerLocationName: 'FreshMart Downtown',
      status: 'CANCELED',
      placedAt: '2026-03-30T12:00:00.000Z',
      totalCents: 4599,
      currency: 'USD',
      itemCount: 3
    }),
    checkout: vi.fn().mockResolvedValue({
      order: {
        orderId: 'order-1',
        externalOrderId: 'ORD-10001',
        retailerId: 'ret-1',
        retailerName: 'FreshMart',
        retailerLocationId: 'loc-1',
        retailerLocationName: 'FreshMart Downtown',
        status: 'SUBMITTED',
        placedAt: '2026-03-30T12:00:00.000Z',
        totalCents: 4599,
        currency: 'USD',
        itemCount: 3
      },
      pricing: {
        subtotalCents: 3000,
        serviceFeeCents: 199,
        deliveryFeeCents: 499,
        estimatedTaxCents: 151,
        tipCents: 750,
        totalCents: 4599,
        currency: 'USD'
      },
      payment: {
        paymentId: 'payment-1',
        status: 'AUTHORIZED',
        amountCents: 4599,
        currency: 'USD'
      },
      delivery: {
        deliveryId: 'delivery-1',
        status: 'PENDING_ASSIGNMENT',
        pickupLocation: 'FreshMart Downtown'
      }
    }),
    getDriverBootstrap: vi.fn().mockResolvedValue({
      driver: {
        id: 'driver-1',
        email: 'driver@example.com',
        fullName: 'Driver Example',
        status: 'ONLINE'
      },
      availableJobs: [],
      activeJobs: [],
      completedJobs: [],
      supportTickets: [],
      earningsSummary: {
        todayGrossCents: 0,
        tipsCents: 0,
        bonusCents: 0,
        nextPayoutLabel: 'Tomorrow 9:00 AM'
      }
    }),
    acceptDelivery: vi.fn().mockResolvedValue({ deliveryId: 'delivery-1', stage: 'assigned' }),
    pickupDelivery: vi
      .fn()
      .mockResolvedValue({ deliveryId: 'delivery-1', stage: 'out_for_delivery' }),
    completeDelivery: vi.fn().mockResolvedValue({ deliveryId: 'delivery-1', stage: 'delivered' })
  } as unknown as MobileRepository;
}

describe('mobile routes', () => {
  it('returns customer bootstrap payloads for authenticated customers', async () => {
    const mobileService = makeMobileService();
    const response = await request(makeApp(mobileService))
      .get('/v1/mobile/customer/bootstrap')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(mobileService.getCustomerBootstrap).toHaveBeenCalled();
  });

  it('rejects invalid customer catalog queries', async () => {
    const response = await request(makeApp())
      .get('/v1/mobile/customer/catalog')
      .query({ retailerLocationId: 'bad-id' })
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
  });

  it('passes validated checkout payloads to the mobile service', async () => {
    const mobileService = makeMobileService();
    const response = await request(makeApp(mobileService))
      .post('/v1/mobile/customer/checkout')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        cartId: '11111111-1111-4111-8111-111111111111',
        addressId: '22222222-2222-4222-8222-222222222222',
        deliveryNotes: 'Leave with concierge',
        tipCents: 750
      });

    expect(response.status).toBe(201);
    expect(mobileService.checkout).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'cust-1', role: 'customer' }),
      {
        cartId: '11111111-1111-4111-8111-111111111111',
        addressId: '22222222-2222-4222-8222-222222222222',
        deliveryNotes: 'Leave with concierge',
        tipCents: 750
      }
    );
  });

  it('calls retailer connect and disconnect endpoints with the authenticated customer', async () => {
    const mobileService = makeMobileService();

    const connect = await request(makeApp(mobileService))
      .post('/v1/mobile/customer/retailers/ret-1/connect')
      .set('authorization', makeBearer('cust-1', 'customer'));

    const disconnect = await request(makeApp(mobileService))
      .post('/v1/mobile/customer/retailers/ret-1/disconnect')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(connect.status).toBe(200);
    expect(connect.body).toMatchObject({ retailerId: 'ret-1', isConnected: true });
    expect(disconnect.status).toBe(200);
    expect(disconnect.body).toMatchObject({ retailerId: 'ret-1', isConnected: false });
    expect(mobileService.connectRetailer).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'cust-1', role: 'customer' }),
      'ret-1'
    );
    expect(mobileService.disconnectRetailer).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'cust-1', role: 'customer' }),
      'ret-1'
    );
  });

  it('forwards customer cancel requests to the mobile service', async () => {
    const mobileService = makeMobileService();

    const response = await request(makeApp(mobileService))
      .post('/v1/mobile/customer/orders/order-1/cancel')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ orderId: 'order-1', status: 'CANCELED' });
    expect(mobileService.cancelOrder).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'cust-1', role: 'customer' }),
      'order-1'
    );
  });

  it('returns not found when the requested order does not exist', async () => {
    const mobileService = makeMobileService();
    mobileService.cancelOrder.mockRejectedValueOnce(
      new HttpError(404, 'NOT_FOUND', 'Order not found.')
    );

    const response = await request(makeApp(mobileService))
      .post('/v1/mobile/customer/orders/missing-order/cancel')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(404);
    expect(response.body).toMatchObject({
      error: 'NOT_FOUND',
      message: 'Order not found.'
    });
  });

  it('returns conflict when the order can no longer be canceled', async () => {
    const mobileService = makeMobileService();
    mobileService.cancelOrder.mockRejectedValueOnce(
      new HttpError(409, 'CONFLICT', 'Order can no longer be canceled.')
    );

    const response = await request(makeApp(mobileService))
      .post('/v1/mobile/customer/orders/order-1/cancel')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(409);
    expect(response.body).toMatchObject({
      error: 'CONFLICT',
      message: 'Order can no longer be canceled.'
    });
  });

  it('returns driver bootstrap payloads for authenticated drivers', async () => {
    const mobileService = makeMobileService();

    const response = await request(makeApp(mobileService))
      .get('/v1/mobile/driver/bootstrap')
      .set('authorization', makeBearer('driver-1', 'driver'));

    expect(response.status).toBe(200);
    expect(mobileService.getDriverBootstrap).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'driver-1', role: 'driver' })
    );
  });

  it('wraps driver delivery action results in a job payload', async () => {
    const mobileService = makeMobileService();

    const accept = await request(makeApp(mobileService))
      .post('/v1/mobile/driver/deliveries/delivery-1/accept')
      .set('authorization', makeBearer('driver-1', 'driver'));

    const complete = await request(makeApp(mobileService))
      .post('/v1/mobile/driver/deliveries/delivery-1/complete')
      .set('authorization', makeBearer('driver-1', 'driver'));

    expect(accept.status).toBe(200);
    expect(accept.body).toMatchObject({ job: { deliveryId: 'delivery-1', stage: 'assigned' } });
    expect(complete.status).toBe(200);
    expect(complete.body).toMatchObject({
      job: { deliveryId: 'delivery-1', stage: 'delivered' }
    });
  });

  it('returns domain errors from driver workflow actions', async () => {
    const mobileService = makeMobileService();
    mobileService.pickupDelivery.mockRejectedValueOnce(
      new HttpError(409, 'CONFLICT', 'Delivery is not ready for pickup.')
    );

    const response = await request(makeApp(mobileService))
      .post('/v1/mobile/driver/deliveries/delivery-1/pickup')
      .set('authorization', makeBearer('driver-1', 'driver'));

    expect(response.status).toBe(409);
    expect(response.body).toMatchObject({
      error: 'CONFLICT',
      message: 'Delivery is not ready for pickup.'
    });
  });

  it('returns forbidden when a driver hits a customer-only endpoint', async () => {
    const service = new MobileService(makeRepository());

    const response = await request(makeApp(service))
      .get('/v1/mobile/customer/bootstrap')
      .set('authorization', makeBearer('driver-1', 'driver'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
  });

  it('returns forbidden when a customer hits a driver-only endpoint', async () => {
    const service = new MobileService(makeRepository());

    const response = await request(makeApp(service))
      .get('/v1/mobile/driver/bootstrap')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
  });
});
