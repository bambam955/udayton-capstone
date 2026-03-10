import type { NextFunction, Request, Response } from 'express';

import { HttpError } from '../errors.js';

// This is the middleware definition for ensuring that all errors are returned to the frontend
// in a robust and secure manner.
export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof HttpError) {
    // Domain errors control both status code and stable API error code.
    res.status(err.statusCode).json({
      error: err.code,
      message: err.message
    });
    return;
  }

  // Unknown failures are intentionally generic to avoid leaking internals.
  res.status(500).json({
    error: 'INTERNAL_SERVER_ERROR',
    message: 'Unexpected error.'
  });
}
