import type { AuthRole } from '../platform/auth/jwt.js';

export interface AuthPrincipal {
  // Internal principal id from the role-specific table.
  userId: string;
  role: AuthRole;
  sessionId: string;
}
