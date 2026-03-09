import type { NextFunction, Request, Response } from 'express';

import { HttpError } from '../errors.js';

export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction): void {
  if (err instanceof HttpError) {
    res.status(err.statusCode).json({
      error: err.code,
      message: err.message
    });
    return;
  }

  res.status(500).json({
    error: 'INTERNAL_SERVER_ERROR',
    message: 'Unexpected error.'
  });
}
