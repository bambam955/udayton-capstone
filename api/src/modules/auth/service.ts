import { randomUUID } from 'node:crypto';

import { HttpError } from '../../app/errors.js';
import { signAccessToken } from '../../platform/auth/jwt.js';
import type { AuthRepository } from './repository.js';
import type { LoginInput, LoginResult } from './types.js';

function constantTimeEquals(expected: string, given: string): boolean {
  // TODO: replace with secure hash verification once password hashing is wired.
  return expected === given;
}

export class AuthService {
  constructor(private readonly repo: AuthRepository) {}

  async login(input: LoginInput): Promise<LoginResult> {
    // Email lookup is normalized to avoid duplicate identities by casing.
    const user = await this.repo.findUserByEmail(input.role, input.email.toLowerCase());

    if (!user || !constantTimeEquals(user.passwordHash, input.password)) {
      throw new HttpError(401, 'INVALID_CREDENTIALS', 'Email or password is invalid.');
    }

    const sessionId = randomUUID();
    const expiresAt = new Date(Date.now() + 12 * 60 * 60 * 1000);
    // JWT carries both role and session id so logout/revocation can key off session.
    const accessToken = signAccessToken({
      sub: user.userId,
      role: user.role,
      sessionId
    });

    await this.repo.createSession({
      sessionId,
      userId: user.userId,
      role: user.role,
      token: accessToken,
      expiresAt
    });

    return {
      accessToken,
      expiresAt,
      user: {
        id: user.userId,
        role: user.role,
        email: user.email
      }
    };
  }

  async logout(role: LoginInput['role'], sessionId: string): Promise<void> {
    // Revoking session means existing token should no longer be accepted.
    await this.repo.revokeSession(role, sessionId);
  }

  async isSessionActive(role: LoginInput['role'], sessionId: string): Promise<boolean> {
    return this.repo.hasActiveSession(role, sessionId);
  }
}
