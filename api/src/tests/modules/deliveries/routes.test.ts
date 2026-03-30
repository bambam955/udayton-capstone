import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('delivery routes', () => {
  it('allows drivers to update their delivery offer response fields', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .patch('/v1/delivery-offers/offer-1')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        status: 'ACCEPTED',
        decline_reason: null
      });

    expect(response.status).toBe(200);
    expect(response.body.data).toMatchObject({
      status: 'ACCEPTED'
    });
    expect(repository.update).toHaveBeenCalled();
  });

  it('blocks customers from creating delivery proof records', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/delivery-proof')
      .set('authorization', makeBearer('cust-1', 'customer'))
      .send({
        delivery_id: 'delivery-1',
        proof_type: 'PHOTO'
      });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.create).not.toHaveBeenCalled();
  });

  it('rejects invalid decimal payloads for delivery status events', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .post('/v1/delivery-status-events')
      .set('authorization', makeBearer('driver-1', 'driver'))
      .send({
        delivery_id: 'delivery-1',
        status: 'IN_TRANSIT',
        lat: 'north'
      });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
    expect(repository.create).not.toHaveBeenCalled();
  });
});
