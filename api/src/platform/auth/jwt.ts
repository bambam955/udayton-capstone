import jwt from 'jsonwebtoken';

import { env } from '../../config/env.js';

export type AuthRole = 'customer' | 'driver' | 'admin';

// Claims required by middleware to build req.principal.
export interface AccessTokenPayload {
  sub: string;
  role: AuthRole;
  sessionId: string;
}

export function signAccessToken(payload: AccessTokenPayload): string {
  // Token lifetime should stay aligned with DB session expiration.
  return jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: '12h'
  });
}

export function verifyAccessToken(token: string): AccessTokenPayload {
  // jsonwebtoken throws on invalid/expired signatures; caller maps that to 401.
  return jwt.verify(token, env.JWT_SECRET) as AccessTokenPayload;
}
