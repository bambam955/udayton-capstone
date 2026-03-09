import jwt from 'jsonwebtoken';

import { env } from '../../config/env.js';

export type AuthRole = 'customer' | 'driver' | 'admin';

export interface AccessTokenPayload {
  sub: string;
  role: AuthRole;
  sessionId: string;
}

export function signAccessToken(payload: AccessTokenPayload): string {
  return jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: '12h',
    subject: payload.sub
  });
}

export function verifyAccessToken(token: string): AccessTokenPayload {
  return jwt.verify(token, env.JWT_SECRET) as AccessTokenPayload;
}
