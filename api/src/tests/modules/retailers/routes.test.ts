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

  it('rejects retailer account creates that omit the retailer id', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/retailer-accounts')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        is_connected: true
      });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
    expect(repository.create).not.toHaveBeenCalled();
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

  it('allows customers to list retailer locations', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/retailer-locations')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('allows drivers to list retailer locations', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/retailer-locations')
      .set('authorization', makeBearer('driver-1', 'driver'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('rejects customer writes to retailer locations', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/retailer-locations')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        retailer_id: 'ret-1',
        name: 'Downtown Market',
        city: 'Charlotte',
        state: 'NC',
        is_active: true
      });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.create).not.toHaveBeenCalled();
  });

  it('rejects driver updates to retailer locations', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .patch('/v1/retailer-locations/location-1')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        name: 'Airport Market'
      });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.update).not.toHaveBeenCalled();
  });

  it('allows admins to manage retailer locations', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const created = await request(app)
      .post('/v1/retailer-locations')
      .set('authorization', makeBearer('admin-1', 'admin'))
      .send({
        retailer_id: 'ret-1',
        external_store_id: 'store-1',
        name: 'Downtown Market',
        city: 'Charlotte',
        state: 'NC',
        is_active: true
      });

    const updated = await request(app)
      .patch('/v1/retailer-locations/location-1')
      .set('authorization', makeBearer('admin-1', 'admin'))
      .send({
        name: 'Uptown Market'
      });

    const deleted = await request(app)
      .delete('/v1/retailer-locations/location-1')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(created.status).toBe(201);
    expect(created.body.data).toMatchObject({
      retailer_id: 'ret-1',
      external_store_id: 'store-1',
      name: 'Downtown Market'
    });
    expect(updated.status).toBe(200);
    expect(updated.body.data).toMatchObject({
      name: 'Uptown Market'
    });
    expect(deleted.status).toBe(204);
    expect(repository.create).toHaveBeenCalled();
    expect(repository.update).toHaveBeenCalled();
    expect(repository.delete).toHaveBeenCalled();
  });
});
