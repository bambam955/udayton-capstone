import { Router } from 'express';

import { HttpError } from '../../app/errors.js';
import { requireAuth } from '../../app/middleware/auth.js';
import type { OrdersService } from './service.js';

export function createOrdersRouter(service: OrdersService): Router {
  const router = Router();

  router.get('/my-orders', requireAuth, async (req, res, next) => {
    try {
      if (!req.principal) {
        throw new HttpError(401, 'UNAUTHORIZED', 'A valid bearer token is required.');
      }

      // Optional query param with conservative default for app list views.
      const limitInput = typeof req.query.limit === 'string' ? req.query.limit : '20';
      const limit = Number.parseInt(limitInput, 10);
      const orders = await service.listMyOrders(req.principal, Number.isNaN(limit) ? 20 : limit);
      res.status(200).json({ orders });
    } catch (error) {
      next(error);
    }
  });

  return router;
}
