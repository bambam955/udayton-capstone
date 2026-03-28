import { Router } from 'express';
import { z } from 'zod';

import { HttpError } from '../../app/errors.js';
import { requireAuth } from '../../app/middleware/auth.js';
import type { AuthService } from './service.js';

// Keep transport validation close to the HTTP boundary.
const loginSchema = z.object({
  role: z.enum(['customer', 'driver', 'admin']),
  email: z.email(),
  password: z.string().min(1),
  deviceInfo: z.string().optional()
});

export function createAuthRouter(service: AuthService): Router {
  const isSessionActive = service.isSessionActive.bind(service);
  const router = Router();

  router.post('/login', async (req, res, next) => {
    try {
      // Route-level validation keeps service input fully typed/sanitized.
      const parsed = loginSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new HttpError(
          400,
          'INVALID_REQUEST',
          parsed.error.issues[0]?.message ?? 'Invalid payload.'
        );
      }

      const result = await service.login(parsed.data);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/logout', requireAuth(isSessionActive), async (req, res, next) => {
    try {
      if (!req.principal) {
        throw new HttpError(401, 'UNAUTHORIZED', 'A valid bearer token is required.');
      }

      await service.logout(req.principal.role, req.principal.sessionId);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  });

  router.get('/me', requireAuth(isSessionActive), (req, res) => {
    // Debug/self-introspection endpoint for authenticated clients.
    res.status(200).json({ principal: req.principal });
  });

  return router;
}
