import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('customer routes', () => {
  it('creates carts for the authenticated customer', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/carts')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        retailer_id: 'ret-1',
        status: 'ACTIVE'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      customer_id: 'cust-1',
      retailer_id: 'ret-1',
      status: 'ACTIVE'
    });
  });

  it('allows customers to manage cart items for their carts', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/cart-items')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        cart_id: 'cart-1',
        product_id: 'prod-1',
        quantity: 2,
        substitution_allowed: true
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      cart_id: 'cart-1',
      product_id: 'prod-1',
      quantity: 2,
      substitution_allowed: true
    });
  });

  it('injects the authenticated customer id on address creation', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/addresses')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        label: 'Warehouse',
        line1: '99 Water St'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      customer_id: 'cust-1',
      label: 'Warehouse',
      line1: '99 Water St'
    });
  });

  it('blocks customers from admin-only customer session endpoints', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/customer-sessions')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
  });

  it('lets customers create support tickets tied to their account', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/support-tickets')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        order_id: 'order-1',
        issue_type: 'LATE_DELIVERY',
        message: 'The order arrived late.'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      customer_id: 'cust-1',
      order_id: 'order-1',
      issue_type: 'LATE_DELIVERY'
    });
  });

  it('lets customers create support tickets without an order id for general support', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/support-tickets')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        issue_type: 'ACCOUNT_HELP',
        message: 'I need help updating my account.'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      customer_id: 'cust-1',
      issue_type: 'ACCOUNT_HELP'
    });
  });

  it('lets customers mark notifications as read', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .patch('/v1/notifications/notification-1')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        is_read: true
      });

    expect(response.status).toBe(200);
    expect(response.body.data).toMatchObject({
      is_read: true
    });
  });

  it('allows admins to list customer sessions', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/customer-sessions')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('rejects invalid address query filters', async () => {
    const app = makeTestApp({
      repository: makeRepository(),
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/addresses')
      .query({ is_default: 'sometimes' })
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
  });

  it('rejects customer attempts to patch protected customer fields', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .patch('/v1/customers/cust-1')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({ is_active: false });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.update).not.toHaveBeenCalled();
  });
});
