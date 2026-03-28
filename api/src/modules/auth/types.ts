import type { AuthRole } from '../../platform/auth/jwt.js';

// Canonical user shape returned by auth repository lookups.
export interface AuthUser {
  userId: string;
  role: AuthRole;
  email: string;
  passwordHash: string;
  isActive: boolean;
}

// Session row persisted after a successful login.
export interface SessionRecord {
  sessionId: string;
  userId: string;
  role: AuthRole;
  token: string;
  expiresAt: Date;
}

// Input expected by AuthService.login.
export interface LoginInput {
  role: AuthRole;
  email: string;
  password: string;
  deviceInfo?: string;
}

// Response payload returned to API clients after login.
export interface LoginResult {
  accessToken: string;
  expiresAt: Date;
  user: {
    id: string;
    role: AuthRole;
    email: string;
  };
}
