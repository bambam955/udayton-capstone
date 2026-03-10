import type { Kysely } from 'kysely';

import type { Database } from '../../platform/db/types.js';
import type { AuthRole } from '../../platform/auth/jwt.js';
import type { AuthUser, SessionRecord } from './types.js';

// Contract used by AuthService so business logic is decoupled from SQL details.
export interface AuthRepository {
  findUserByEmail(role: AuthRole, email: string): Promise<AuthUser | null>;
  createSession(session: SessionRecord): Promise<void>;
  revokeSession(role: AuthRole, sessionId: string): Promise<void>;
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
}
