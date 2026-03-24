import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('order routes', () => {
  it('returns 401 without a bearer token', async () => {
    const app = makeTestApp({
      repository: makeRepository(),
      authService: makeAuthService(true)
    });

    const response = await request(app).get('/v1/orders');

    expect(response.status).toBe(401);
  });

  it('returns 401 when a session has been revoked', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(false)
    });

    const response = await request(app)
      .get('/v1/orders')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(401);
    expect(repository.list).not.toHaveBeenCalled();
  });

  it('allows customers to create orders and injects the authenticated customer id', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/orders')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        retailer_id: 'ret-1',
        address_id: 'addr-1',
        status: 'PLACED',
        currency: 'USD',
        total_cents: 4599
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      customer_id: 'cust-1',
      retailer_id: 'ret-1',
      address_id: 'addr-1'
    });
    expect(repository.create).toHaveBeenCalled();
  });

  it('blocks drivers from listing order collections they do not own through the customer surface', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/orders')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        retailer_id: 'ret-1',
        address_id: 'addr-1'
      });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.create).not.toHaveBeenCalled();
  });

  it('rejects invalid boolean filters on order list queries', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/orders')
      .query({ limit: 'oops' })
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
    expect(repository.list).not.toHaveBeenCalled();
  });
});
