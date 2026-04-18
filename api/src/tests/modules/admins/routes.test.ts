import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import {
  makeAuthService,
  makeBearer,
  makeRepository,
  makeTestApp
} from '../../support/resource-test-helpers.js';

describe('admin routes', () => {
  it('allows admins to inspect integration health', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/integration-health')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('allows admins to list admin profiles', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/admin-profiles')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('allows admins to list admin roles', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/admin-roles')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });

  it('returns pagination metadata on resource list responses', async () => {
    const repository = makeRepository();
    repository.list = vi.fn().mockResolvedValue({
      data: [{ admin_id: 'admin-1' }],
      total: 42
    });
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/admins')
      .query({ limit: 10, offset: 5 })
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      data: [{ admin_id: 'admin-1' }],
      meta: {
        total: 42,
        limit: 10,
        offset: 5
      }
    });
  });

  it('blocks customers from reading integration health', async () => {
    const repository = makeRepository();
    const app = makeTestApp({
      repository,
      authService: makeAuthService(true)
    });

    const response = await request(app)
      .get('/v1/integration-health')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
    expect(repository.list).not.toHaveBeenCalled();
  });
});
