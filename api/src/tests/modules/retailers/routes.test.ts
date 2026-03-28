import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('retailer routes', () => {
  it('rejects protected retailer account fields for customer patch requests', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .patch('/v1/retailer-accounts/account-1')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        access_token: 'secret-token'
      });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.update).not.toHaveBeenCalled();
  });

  it('allows unauthenticated roles to read retailer catalogs after authentication', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/products')
      .query({ retailer_id: 'ret-1' })
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('injects the authenticated customer id when creating retailer accounts', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/retailer-accounts')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        retailer_id: 'ret-1',
        is_connected: true
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      customer_id: 'cust-1',
      retailer_id: 'ret-1',
      is_connected: true
    });
  });

  it('allows customers to list service regions for location selection', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/service-regions')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });
});
