import type { AuthRole } from '../../platform/auth/jwt.js';

export interface AuthUser {
  userId: string;
  role: AuthRole;
  email: string;
  passwordHash: string;
  isActive: boolean;
}

export interface SessionRecord {
  sessionId: string;
  userId: string;
  role: AuthRole;
  token: string;
  expiresAt: Date;
}

export interface LoginInput {
  role: AuthRole;
  email: string;
  password: string;
  deviceInfo?: string;
}

export interface LoginResult {
  accessToken: string;
  expiresAt: Date;
  user: {
    id: string;
    role: AuthRole;
    email: string;
  };
}
