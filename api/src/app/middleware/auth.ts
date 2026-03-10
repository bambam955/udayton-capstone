import type { NextFunction, Request, Response } from 'express';

import { verifyAccessToken } from '../../platform/auth/jwt.js';
import type { AuthPrincipal } from '../types.js';

// Extend the Express.Request type.
declare global {
  namespace Express {
    interface Request {
      // Populated by requireAuth and consumed by downstream handlers.
      principal?: AuthPrincipal;
    }
  }
}

function unauthorized(res: Response): void {
  res.status(401).json({
    error: 'UNAUTHORIZED',
    message: 'A valid bearer token is required.'
  });
}

// This is the main middleware definition for adding authentication to a REST endpoint.
export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  // API expects RFC6750-style Authorization header: "Bearer <token>".
  const authHeader = req.header('authorization');

  if (!authHeader?.startsWith('Bearer ')) {
    unauthorized(res);
    return;
  }

  const token = authHeader.slice('Bearer '.length);

  try {
    const decoded = verifyAccessToken(token);
    // Keep request principal minimal and transport-safe.
    req.principal = {
      userId: decoded.sub,
      role: decoded.role,
      sessionId: decoded.sessionId
    };
    next();
  } catch {
    unauthorized(res);
  }
}

export function requireRole(role: AuthPrincipal['role']) {
  // Small guard factory for routes limited to one account role.
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.principal || req.principal.role !== role) {
      res.status(403).json({
        error: 'FORBIDDEN',
        message: 'You do not have access to this resource.'
      });
      return;
    }

    next();
  };
}
