import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { createApp } from '../../../app/createApp.js';
import { HttpError } from '../../../app/errors.js';
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

function makeApp(mobileService = makeMobileService()) {
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
});
