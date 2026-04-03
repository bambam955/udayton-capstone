import { describe, expect, it, vi } from 'vitest';

import { HttpError } from '../../../app/errors.js';
import type { AuthRepository } from '../../../modules/auth/repository.js';
import { AuthService } from '../../../modules/auth/service.js';

function makeRepo(): AuthRepository {
  return {
    findUserByEmail: vi.fn(),
    findUserByCredentials: vi.fn(),
    createCustomer: vi.fn(),
    createSession: vi.fn().mockResolvedValue(undefined),
    revokeSession: vi.fn().mockResolvedValue(undefined),
    hasActiveSession: vi.fn().mockResolvedValue(true)
  };
}

describe('AuthService', () => {
  it('returns access token on valid credentials', async () => {
    const repo = makeRepo();
    vi.mocked(repo.findUserByCredentials).mockResolvedValue({
      userId: 'cust-1',
      role: 'customer',
      email: 'customer@example.com',
      isActive: true
    });
    const service = new AuthService(repo);

    const result = await service.login({
      role: 'customer',
      email: 'customer@example.com',
      password: 'secret123'
    });

    expect(result.accessToken).toBeTypeOf('string');
    expect(result.user.id).toBe('cust-1');
    expect(repo.createSession).toHaveBeenCalledOnce();
  });

  it('throws for invalid credentials', async () => {
    const repo = makeRepo();
    vi.mocked(repo.findUserByCredentials).mockResolvedValue(null);
    const service = new AuthService(repo);

    await expect(
      service.login({ role: 'driver', email: 'driver@example.com', password: 'wrong' })
    ).rejects.toMatchObject({
      statusCode: 401,
      code: 'INVALID_CREDENTIALS'
    } satisfies Partial<HttpError>);
  });

  it('checks session activity by role and sessionId', async () => {
    const repo = makeRepo();
    vi.mocked(repo.hasActiveSession).mockResolvedValueOnce(false);
    const service = new AuthService(repo);

    const isActive = await service.isSessionActive('admin', 'session-1');

    expect(isActive).toBe(false);
    expect(repo.hasActiveSession).toHaveBeenCalledOnce();
    expect(repo.hasActiveSession).toHaveBeenCalledWith('admin', 'session-1');
  });

  it('creates a customer session as part of signup', async () => {
    const repo = makeRepo();
    vi.mocked(repo.findUserByEmail).mockResolvedValue(null);
    vi.mocked(repo.createCustomer).mockResolvedValue({
      userId: 'cust-2',
      role: 'customer',
      email: 'new@example.com',
      isActive: true
    });
    const service = new AuthService(repo);

    const result = await service.signup({
      email: 'new@example.com',
      password: 'secret123',
      fullName: 'New Customer'
    });

    expect(result.user.id).toBe('cust-2');
    expect(result.user.role).toBe('customer');
    expect(repo.createCustomer).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'new@example.com',
        fullName: 'New Customer'
      })
    );
    expect(repo.createSession).toHaveBeenCalledOnce();
  });
});
