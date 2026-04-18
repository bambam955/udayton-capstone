import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { makeAuthService, makeBearer, makeTestApp } from '../../support/resource-test-helpers.js';

describe('admin operations routes', () => {
  it('allows admins to read the dashboard', async () => {
    const adminOperationsService = {
      getDashboard: vi.fn().mockResolvedValue({
        metrics: {
          totalOrders: 5,
          activeDrivers: 3,
          readyForPickupOrders: 1,
          integrationIssues: 1
        },
        recentOrders: [],
        integrationHealth: []
      }),
      updateOrderStatus: vi.fn(),
      issueRefund: vi.fn()
    };
    const app = makeTestApp({
      authService: makeAuthService(true),
      adminOperationsService
    });

    const response = await request(app)
      .get('/v1/admin/dashboard')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(response.body.metrics).toMatchObject({
      totalOrders: 5,
      activeDrivers: 3
    });
    expect(adminOperationsService.getDashboard).toHaveBeenCalled();
  });

  it('blocks non-admins from the dashboard route', async () => {
    const adminOperationsService = {
      getDashboard: vi.fn(),
      updateOrderStatus: vi.fn(),
      issueRefund: vi.fn()
    };
    const app = makeTestApp({
      authService: makeAuthService(true),
      adminOperationsService
    });

    const response = await request(app)
      .get('/v1/admin/dashboard')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(adminOperationsService.getDashboard).not.toHaveBeenCalled();
  });

  it('updates order status for admins', async () => {
    const adminOperationsService = {
      getDashboard: vi.fn(),
      updateOrderStatus: vi.fn().mockResolvedValue({
        order: { order_id: 'order-1', status: 'READY_FOR_PICKUP' },
        historyEntry: { order_id: 'order-1', status: 'READY_FOR_PICKUP' }
      }),
      issueRefund: vi.fn()
    };
    const app = makeTestApp({
      authService: makeAuthService(true),
      adminOperationsService
    });

    const response = await request(app)
      .post('/v1/admin/orders/order-1/status')
      .set('authorization', makeBearer('admin-1', 'admin'))
      .send({
        status: 'READY_FOR_PICKUP',
        note: 'Retailer confirmed pickup readiness.'
      });

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      order: { status: 'READY_FOR_PICKUP' },
      historyEntry: { status: 'READY_FOR_PICKUP' }
    });
    expect(adminOperationsService.updateOrderStatus).toHaveBeenCalledWith(
      expect.objectContaining({ role: 'admin' }),
      'order-1',
      expect.objectContaining({
        status: 'READY_FOR_PICKUP'
      })
    );
  });

  it('rejects invalid order status payloads', async () => {
    const adminOperationsService = {
      getDashboard: vi.fn(),
      updateOrderStatus: vi.fn(),
      issueRefund: vi.fn()
    };
    const app = makeTestApp({
      authService: makeAuthService(true),
      adminOperationsService
    });

    const response = await request(app)
      .post('/v1/admin/orders/order-1/status')
      .set('authorization', makeBearer('admin-1', 'admin'))
      .send({
        status: 'CANCELLED'
      });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
    expect(adminOperationsService.updateOrderStatus).not.toHaveBeenCalled();
  });

  it('creates refunds for admins', async () => {
    const adminOperationsService = {
      getDashboard: vi.fn(),
      updateOrderStatus: vi.fn(),
      issueRefund: vi.fn().mockResolvedValue({
        refund: { refund_id: 'refund-1', amount_cents: 1200, status: 'COMPLETED' }
      })
    };
    const app = makeTestApp({
      authService: makeAuthService(true),
      adminOperationsService
    });

    const response = await request(app)
      .post('/v1/admin/orders/order-1/refund')
      .set('authorization', makeBearer('admin-1', 'admin'))
      .send({
        amountCents: 1200,
        reason: 'Damaged items'
      });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      refund: { amount_cents: 1200, status: 'COMPLETED' }
    });
    expect(adminOperationsService.issueRefund).toHaveBeenCalledWith(
      expect.objectContaining({ role: 'admin' }),
      'order-1',
      {
        amountCents: 1200,
        reason: 'Damaged items'
      }
    );
  });
});
