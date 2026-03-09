import { describe, expect, it, vi } from 'vitest';

import { HttpError } from '../../../app/errors.js';
import type { AuthRepository } from '../../../modules/auth/repository.js';
import { AuthService } from '../../../modules/auth/service.js';

function makeRepo(): AuthRepository {
  return {
    findUserByEmail: vi.fn(),
    createSession: vi.fn().mockResolvedValue(undefined),
    revokeSession: vi.fn().mockResolvedValue(undefined)
  };
}

describe('AuthService', () => {
  it('returns access token on valid credentials', async () => {
    const repo = makeRepo();
    vi.mocked(repo.findUserByEmail).mockResolvedValue({
      userId: 'cust-1',
      role: 'customer',
      email: 'customer@example.com',
      passwordHash: 'secret123',
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
    vi.mocked(repo.findUserByEmail).mockResolvedValue(null);
    const service = new AuthService(repo);

    await expect(
      service.login({ role: 'driver', email: 'driver@example.com', password: 'wrong' })
    ).rejects.toMatchObject({
      statusCode: 401,
      code: 'INVALID_CREDENTIALS'
    } satisfies Partial<HttpError>);
  });
});
