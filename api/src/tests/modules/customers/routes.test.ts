import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { createApp } from '../../../app/createApp.js';
import { allResourceDefinitions } from '../../../modules/shared/resource-core/all-definitions.js';
import { ResourceService } from '../../../modules/shared/resource-core/service.js';
import type { ResourceRepository } from '../../../modules/shared/resource-core/types.js';
import { signAccessToken } from '../../../platform/auth/jwt.js';

function makeRepository(): ResourceRepository {
  return {
    canCreate: vi.fn().mockResolvedValue(true),
    list: vi.fn().mockResolvedValue([]),
    get: vi.fn().mockResolvedValue({ id: 'row-1' }),
    create: vi.fn().mockImplementation(async (_definition, _access, _principal, values) => values),
    update: vi.fn().mockImplementation(async (_definition, _access, _principal, _id, values) => values),
    delete: vi.fn().mockResolvedValue(true)
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

describe('customer routes', () => {
  it('injects the authenticated customer id on address creation', async () => {
    const repository = makeRepository();
    const app = createApp({
      authService: makeAuthService(true) as never,
      resourceService: new ResourceService(repository, allResourceDefinitions)
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
    const app = createApp({
      authService: makeAuthService(true) as never,
      resourceService: new ResourceService(repository, allResourceDefinitions)
    });

    const response = await request(app)
      .get('/v1/customer-sessions')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(403);
    expect(response.body).toMatchObject({ error: 'FORBIDDEN' });
  });

  it('allows admins to list customer sessions', async () => {
    const repository = makeRepository();
    const app = createApp({
      authService: makeAuthService(true) as never,
      resourceService: new ResourceService(repository, allResourceDefinitions)
    });

    const response = await request(app)
      .get('/v1/customer-sessions')
      .set('authorization', makeBearer('admin-1', 'admin'));

    expect(response.status).toBe(200);
    expect(repository.list).toHaveBeenCalled();
  });
});
