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

      const limit = Number.parseInt(String(req.query.limit ?? '20'), 10);
      const orders = await service.listMyOrders(req.principal, Number.isNaN(limit) ? 20 : limit);
      res.status(200).json({ orders });
    } catch (error) {
      next(error);
    }
  });

  return router;
}
