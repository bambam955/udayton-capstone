import { Router } from 'express';
import { z } from 'zod';

import { HttpError } from '../../app/errors.js';
import { requireAuth } from '../../app/middleware/auth.js';
import type { OrdersService } from './service.js';
import type { AuthService } from '../auth/service.js';

const listOrdersQuerySchema = z.object({
  limit: z.coerce.number().int().positive().default(20),
  customerId: z.string().min(1).optional()
});

export function createOrdersRouter(
  service: OrdersService,
  authService: Pick<AuthService, 'isSessionActive'>
): Router {
  const isSessionActive = authService.isSessionActive.bind(authService);
  const router = Router();

  router.get('/', requireAuth(isSessionActive), async (req, res, next) => {
    try {
      if (!req.principal) {
        throw new HttpError(401, 'UNAUTHORIZED', 'A valid bearer token is required.');
      }

      const parsed = listOrdersQuerySchema.safeParse(req.query);
      if (!parsed.success) {
        throw new HttpError(
          400,
          'INVALID_REQUEST',
          parsed.error.issues[0]?.message ?? 'Invalid query parameters.'
        );
      }

      // Service layer handles role policy and customerId access controls.
      const orders = await service.listOrders(req.principal, parsed.data);
      res.status(200).json({ orders });
    } catch (error) {
      next(error);
    }
  });

  return router;
}
