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

describe('retailer routes', () => {
  it('rejects protected retailer account fields for customer patch requests', async () => {
    const repository = makeRepository();
    const app = createApp({
      authService: makeAuthService(true) as never,
      resourceService: new ResourceService(repository, allResourceDefinitions)
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
});
