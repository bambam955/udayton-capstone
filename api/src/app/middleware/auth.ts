import type { NextFunction, Request, Response } from 'express';

import { verifyAccessToken } from '../../platform/auth/jwt.js';
import type { AuthPrincipal } from '../types.js';

declare global {
  namespace Express {
    interface Request {
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

export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.header('authorization');

  if (!authHeader?.startsWith('Bearer ')) {
    unauthorized(res);
    return;
  }

  const token = authHeader.slice('Bearer '.length);

  try {
    const decoded = verifyAccessToken(token);
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
