import type { Kysely } from 'kysely';

import { HttpError } from '../../app/errors.js';
import type { Database } from '../../platform/db/types.js';
import type { AuthRole } from '../../platform/auth/jwt.js';
import type { AuthUser, SessionRecord, SignupInput } from './types.js';

// Contract used by AuthService so business logic is decoupled from SQL details.
export interface AuthRepository {
  findUserByEmail(role: AuthRole, email: string): Promise<AuthUser | null>;
  createCustomer(input: SignupInput): Promise<AuthUser>;
  createSession(session: SessionRecord): Promise<void>;
  revokeSession(role: AuthRole, sessionId: string): Promise<void>;
  hasActiveSession(role: AuthRole, sessionId: string): Promise<boolean>;
}

// Kysely implementation of the AuthRepository interface.
export class KyselyAuthRepository implements AuthRepository {
  constructor(private readonly db: Kysely<Database>) {}

  async findUserByEmail(role: AuthRole, email: string): Promise<AuthUser | null> {
    // Each role maps to a separate table in the current schema.
    if (role === 'customer') {
      const row = await this.db
        .selectFrom('customers')
        .select(['customer_id', 'email', 'password_hash', 'is_active'])
        .where('email', '=', email)
        .executeTakeFirst();
      if (!row?.email || !row.password_hash || row.is_active !== true) {
        return null;
      }
      return {
        userId: row.customer_id,
        role,
        email: row.email,
        passwordHash: row.password_hash,
        isActive: true
      };
    }

    if (role === 'driver') {
      const row = await this.db
        .selectFrom('drivers')
        .select(['driver_id', 'email', 'password_hash', 'is_active'])
        .where('email', '=', email)
        .executeTakeFirst();
      if (!row?.email || !row.password_hash || row.is_active !== true) {
        return null;
      }
      return {
        userId: row.driver_id,
        role,
        email: row.email,
        passwordHash: row.password_hash,
        isActive: true
      };
    }

    const row = await this.db
      .selectFrom('admins')
      .select(['admin_id', 'email', 'password_hash', 'is_active'])
      .where('email', '=', email)
      .executeTakeFirst();
    if (!row?.email || !row.password_hash || row.is_active !== true) {
      return null;
    }
    return {
      userId: row.admin_id,
      role,
      email: row.email,
      passwordHash: row.password_hash,
      isActive: true
    };
  }

  async createCustomer(input: SignupInput): Promise<AuthUser> {
    try {
      // Registration still stores the raw password until hashing is wired in.
      const row = await this.db
        .insertInto('customers')
        .values({
          email: input.email.toLowerCase(),
          phone: input.phone ?? null,
          full_name: input.fullName ?? null,
          password_hash: input.password,
          is_active: true,
          created_at: new Date(),
          updated_at: new Date()
        })
        .returning(['customer_id', 'email', 'password_hash'])
        .executeTakeFirstOrThrow();

      return {
        userId: row.customer_id,
        role: 'customer',
        email: row.email ?? input.email.toLowerCase(),
        passwordHash: row.password_hash ?? input.password,
        isActive: true
      };
    } catch (error) {
      // The MVP schema enforces unique customer emails, so surface a stable API error.
      if (
        typeof error === 'object' &&
        error !== null &&
        'code' in error &&
        error.code === '23505'
      ) {
        throw new HttpError(409, 'CONFLICT', 'An account with that email already exists.');
      }

      throw error;
    }
  }

  async createSession(session: SessionRecord): Promise<void> {
    // Sessions are role-scoped and persisted to matching session tables.
    if (session.role === 'customer') {
      await this.db
        .insertInto('customer_sessions')
        .values({
          session_id: session.sessionId,
          customer_id: session.userId,
          access_token: session.token,
          expires_at: session.expiresAt,
          created_at: new Date()
        })
        .execute();
      return;
    }

    if (session.role === 'driver') {
      await this.db
        .insertInto('driver_sessions')
        .values({
          session_id: session.sessionId,
          driver_id: session.userId,
          access_token: session.token,
          expires_at: session.expiresAt,
          created_at: new Date()
        })
        .execute();
      return;
    }

    await this.db
      .insertInto('admin_sessions')
      .values({
        session_id: session.sessionId,
        admin_id: session.userId,
        access_token: session.token,
        expires_at: session.expiresAt,
        created_at: new Date()
      })
      .execute();
  }

  async revokeSession(role: AuthRole, sessionId: string): Promise<void> {
    if (role === 'customer') {
      await this.db.deleteFrom('customer_sessions').where('session_id', '=', sessionId).execute();
      return;
    }

    if (role === 'driver') {
      await this.db.deleteFrom('driver_sessions').where('session_id', '=', sessionId).execute();
      return;
    }

    await this.db.deleteFrom('admin_sessions').where('session_id', '=', sessionId).execute();
  }

  async hasActiveSession(role: AuthRole, sessionId: string): Promise<boolean> {
    if (role === 'customer') {
      const row = await this.db
        .selectFrom('customer_sessions')
        .select('session_id')
        .where('session_id', '=', sessionId)
        .executeTakeFirst();

      return row !== undefined && row.session_id !== null;
    }

    if (role === 'driver') {
      const row = await this.db
        .selectFrom('driver_sessions')
        .select('session_id')
        .where('session_id', '=', sessionId)
        .executeTakeFirst();

      return row !== undefined && row.session_id !== null;
    }

    const row = await this.db
      .selectFrom('admin_sessions')
      .select('session_id')
      .where('session_id', '=', sessionId)
      .executeTakeFirst();

    return row !== undefined && row.session_id !== null;
  }
}
