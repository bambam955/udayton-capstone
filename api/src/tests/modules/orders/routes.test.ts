import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { createApp } from '../../../app/createApp.js';
import { signAccessToken } from '../../../platform/auth/jwt.js';
import type { OrdersRepository } from '../../../modules/orders/repository.js';
import { OrdersService } from '../../../modules/orders/service.js';

function makeRepo(): OrdersRepository {
  return {
    listByCustomer: vi.fn().mockResolvedValue([]),
    listRecent: vi.fn().mockResolvedValue([])
  };
}

function makeBearer(userId: string, role: 'customer' | 'driver' | 'admin'): string {
  const token = signAccessToken({
    sub: userId,
    role,
    sessionId: `session-${role}-1`
  });
  return `Bearer ${token}`;
}

function makeAuthService(isSessionActive = true): object {
  return {
    login: vi.fn(),
    logout: vi.fn(),
    isSessionActive: vi.fn().mockResolvedValue(isSessionActive)
  };
}

describe('orders routes', () => {
  it('returns 401 without bearer token', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(true) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app).get('/v1/orders');

    expect(response.status).toBe(401);
  });

  it('returns customer orders for the authenticated customer', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(true) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app)
      .get('/v1/orders')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(vi.mocked(repo.listByCustomer)).toHaveBeenCalledWith('cust-1', 20);
  });

  it('returns 403 when customer requests another customerId', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(true) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app)
      .get('/v1/orders')
      .query({ customerId: 'cust-2' })
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
  });

  it('returns all recent orders for admin without customerId', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(true) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app)
      .get('/v1/orders')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(vi.mocked(repo.listRecent)).toHaveBeenCalledWith(20);
  });

  it('filters by customerId for admin', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(true) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app)
      .get('/v1/orders')
      .query({ customerId: 'cust-9' })
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(vi.mocked(repo.listByCustomer)).toHaveBeenCalledWith('cust-9', 20);
  });

  it('returns 403 for driver role', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(true) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app)
      .get('/v1/orders')
      .set('authorization', makeBearer('driver-1', 'driver'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
  });

  it('returns 401 when session is revoked', async () => {
    const repo = makeRepo();
    const app = createApp({
      authService: makeAuthService(false) as never,
      ordersService: new OrdersService(repo)
    });

    const response = await request(app)
      .get('/v1/orders')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(401);
    expect(response.body).toMatchObject({ error: 'UNAUTHORIZED' });
    expect(vi.mocked(repo.listByCustomer)).not.toHaveBeenCalled();
  });
});
