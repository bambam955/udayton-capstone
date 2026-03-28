import { Router } from 'express';

export const healthRouter = Router();

// Lightweight liveness endpoint for health checks.
healthRouter.get('/', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});
