import { Router } from 'express';

export const healthRouter = Router();

// Lightweight liveness endpoint for compose/k8s health checks.
healthRouter.get('/', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});
