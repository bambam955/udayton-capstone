import type { AuthRole } from '../platform/auth/jwt.js';

export interface AuthPrincipal {
  userId: string;
  role: AuthRole;
  sessionId: string;
}
