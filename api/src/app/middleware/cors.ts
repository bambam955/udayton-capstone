import type { NextFunction, Request, Response } from 'express';

import type { Env } from '../../config/env.js';

const LOCALHOST_HOSTS = new Set(['localhost', '127.0.0.1']);
const DEFAULT_ALLOWED_HEADERS = 'authorization, content-type';
const DEFAULT_ALLOWED_METHODS = 'GET, POST, PUT, PATCH, DELETE, OPTIONS';

/**
 * Browsers enforce CORS only for cross-origin requests, so native/mobile
 * clients continue to work even when they do not send an Origin header.
 *
 * During local development the Flutter web app often runs on a host-selected
 * localhost port, so we allow any localhost/127.0.0.1 origin in non-production
 * environments instead of forcing developers to keep a port list in sync.
 */
export function createCorsMiddleware(env: Env) {
  return function corsMiddleware(req: Request, res: Response, next: NextFunction) {
    const origin = req.header('origin');
    const allowedOrigin = resolveAllowedOrigin(origin, env);

    if (allowedOrigin) {
      res.header('Access-Control-Allow-Origin', allowedOrigin);
      res.header('Vary', 'Origin');
      res.header('Access-Control-Allow-Credentials', 'true');
      res.header('Access-Control-Allow-Methods', DEFAULT_ALLOWED_METHODS);

      // Mirror the browser's requested headers when present so preflight stays
      // compatible with any future custom headers added by the web clients.
      const requestedHeaders = req.header('access-control-request-headers');
      res.header(
        'Access-Control-Allow-Headers',
        requestedHeaders?.trim() || DEFAULT_ALLOWED_HEADERS
      );
    }

    if (req.method === 'OPTIONS') {
      res.sendStatus(allowedOrigin ? 204 : 403);
      return;
    }

    next();
  };
}

function resolveAllowedOrigin(origin: string | undefined, env: Env) {
  if (!origin) {
    return null;
  }

  if (isConfiguredOrigin(origin, env)) {
    return origin;
  }

  if (env.NODE_ENV !== 'production' && isLocalDevelopmentOrigin(origin)) {
    return origin;
  }

  return null;
}

function isConfiguredOrigin(origin: string, env: Env) {
  return env.CORS_ALLOWED_ORIGINS.includes(origin);
}

function isLocalDevelopmentOrigin(origin: string) {
  try {
    const parsedOrigin = new URL(origin);
    return LOCALHOST_HOSTS.has(parsedOrigin.hostname);
  } catch {
    return false;
  }
}
