import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('driver routes', () => {
  it('lets drivers create their onboarding profile', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/driver-profiles')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        date_of_birth: '1990-01-01',
        license_number: 'D1234567',
        license_state: 'NY'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      driver_id: 'driver-1',
      license_number: 'D1234567',
      license_state: 'NY'
    });
  });

  it('lets drivers register vehicles', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/driver-vehicles')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        make: 'Toyota',
        model: 'Corolla',
        year: 2021,
        is_primary: true
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      driver_id: 'driver-1',
      make: 'Toyota',
      model: 'Corolla',
      is_primary: true
    });
  });

  it('injects the authenticated driver id when creating a location update', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/driver-locations')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        lat: 40.7128,
        lng: -74.006,
        source: 'gps'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      driver_id: 'driver-1',
      source: 'gps'
    });
    expect(repository.create).toHaveBeenCalled();
  });

  it('blocks customers from listing driver payouts', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/driver-payouts')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.list).not.toHaveBeenCalled();
  });

  it('lets drivers publish availability updates', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/driver-availability')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        is_available: true,
        reason: 'ONLINE'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      driver_id: 'driver-1',
      is_available: true,
      reason: 'ONLINE'
    });
  });

  it('allows admins to list driver sessions', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/driver-sessions')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });
});
