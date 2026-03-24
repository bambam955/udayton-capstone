import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('customer routes', () => {
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
