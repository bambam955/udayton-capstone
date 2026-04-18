import { Router } from 'express';
import { z } from 'zod';

import { HttpError } from '../../app/errors.js';
import { requireAuth, requireRole } from '../../app/middleware/auth.js';
import type { AuthService } from '../auth/service.js';
import { orderStatuses } from '../orders/statuses.js';
import type { AdminOperationsService } from './operations-service.js';

const updateOrderStatusSchema = z.object({
  status: z.enum(orderStatuses),
  note: z.string().min(1).optional()
});

const issueRefundSchema = z.object({
  amountCents: z.coerce.number().int().positive(),
  reason: z.string().min(1)
});

function requirePrincipal(principal: Express.Request['principal']) {
  if (!principal) {
    throw new HttpError(401, 'UNAUTHORIZED', 'A valid bearer token is required.');
  }

  return principal;
}

export function createAdminOperationsRouter(
  service: AdminOperationsService,
  authService: AuthService
) {
  const router = Router();
  const isSessionActive = authService.isSessionActive.bind(authService);

  router.use(requireAuth(isSessionActive));
  router.use(requireRole('admin'));

  router.get('/dashboard', async (req, res, next) => {
    try {
      const result = await service.getDashboard(requirePrincipal(req.principal));
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/orders/:orderId/status', async (req, res, next) => {
    try {
      const parsed = updateOrderStatusSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new HttpError(
          400,
          'INVALID_REQUEST',
          parsed.error.issues[0]?.message ?? 'Invalid payload.'
        );
      }

      const result = await service.updateOrderStatus(
        requirePrincipal(req.principal),
        req.params.orderId,
        parsed.data
      );
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/orders/:orderId/refund', async (req, res, next) => {
    try {
      const parsed = issueRefundSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new HttpError(
          400,
          'INVALID_REQUEST',
          parsed.error.issues[0]?.message ?? 'Invalid payload.'
        );
      }

      const result = await service.issueRefund(
        requirePrincipal(req.principal),
        req.params.orderId,
        parsed.data
      );
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  });

  return router;
}
