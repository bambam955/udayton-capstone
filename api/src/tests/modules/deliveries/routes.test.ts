import request from 'supertest';
import { describe, expect, it } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('delivery routes', () => {
  it('blocks drivers from updating delivery offers outside the guarded mobile flow', async () => {
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

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.update).not.toHaveBeenCalled();
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

  it('blocks drivers from creating delivery status events outside the guarded mobile flow', async () => {
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
        lat: 35.0
      });

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.create).not.toHaveBeenCalled();
  });
});
