import { createApp } from '../../app/createApp.js';
import { allResourceDefinitions } from '../../modules/shared/resource-core/all-definitions.js';
import { ResourceService } from '../../modules/shared/resource-core/service.js';
import type { ResourceRepository } from '../../modules/shared/resource-core/types.js';
import { signAccessToken } from '../../platform/auth/jwt.js';
import { vi } from 'vitest';

export function makeRepository(): ResourceRepository {
  return {
    canCreate: vi.fn().mockResolvedValue(true),
    list: vi.fn().mockResolvedValue({ data: [], total: 0 }),
    get: vi.fn().mockResolvedValue({ id: 'row-1' }),
    create: vi.fn().mockImplementation(async (_definition, _access, _principal, values) => values),
    update: vi
      .fn()
      .mockImplementation(async (_definition, _access, _principal, _id, values) => values),
    delete: vi.fn().mockResolvedValue(true)
  };
}

export function makeBearer(userId: string, role: 'customer' | 'driver' | 'admin'): string {
  // Reuse the real JWT signing path so auth middleware behavior matches production.
  const token = signAccessToken({
    sub: userId,
    role,
    sessionId: `session-${role}-1`
  });

  return `Bearer ${token}`;
}

export function makeAuthService(isSessionActive = true): object {
  return {
    login: vi.fn().mockResolvedValue({
      accessToken: 'token',
      expiresAt: new Date(),
      user: { id: 'u1', role: 'customer', email: 'user@example.com' }
    }),
    logout: vi.fn().mockResolvedValue(undefined),
    isSessionActive: vi.fn().mockResolvedValue(isSessionActive)
  };
}

export function makeTestApp(options?: {
  repository?: ResourceRepository;
  authService?: object;
  adminOperationsService?: object;
}) {
  const repository = options?.repository ?? makeRepository();
  const authService = options?.authService ?? makeAuthService(true);

  return createApp({
    authService: authService as never,
    resourceService: new ResourceService(repository, allResourceDefinitions),
    adminOperationsService: options?.adminOperationsService as never,
    // Resource route tests do not exercise mobile behavior, but wiring a small
    // mock keeps the optional mobile route available for integration-style tests.
    mobileService: {
      getCustomerBootstrap: vi.fn(),
      getCustomerCatalog: vi.fn(),
      connectRetailer: vi.fn(),
      disconnectRetailer: vi.fn(),
      checkout: vi.fn(),
      getDriverBootstrap: vi.fn(),
      acceptDelivery: vi.fn(),
      pickupDelivery: vi.fn(),
      completeDelivery: vi.fn()
    }
  });
}
