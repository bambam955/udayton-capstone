import { Router } from 'express';
import { z } from 'zod';

import { HttpError } from '../../app/errors.js';
import { requireAuth } from '../../app/middleware/auth.js';
import type { AuthPrincipal } from '../../app/types.js';
import type { AuthService } from '../auth/service.js';
import type { MobileServiceContract } from './types.js';

const customerCatalogQuerySchema = z.object({
  retailerLocationId: z.string().uuid(),
  category: z.string().min(1).optional(),
  query: z.string().min(1).optional()
});

const checkoutSchema = z.object({
  cartId: z.string().uuid(),
  addressId: z.string().uuid(),
  deliveryNotes: z.string().min(1).optional(),
  tipCents: z.coerce.number().int().min(0).optional()
});

function requirePrincipal(principal: AuthPrincipal | undefined): AuthPrincipal {
  if (!principal) {
    throw new HttpError(401, 'UNAUTHORIZED', 'A valid bearer token is required.');
  }

  return principal;
}

export function createMobileRouter(
  service: MobileServiceContract,
  authService: AuthService
): Router {
  const router = Router();
  const isSessionActive = authService.isSessionActive.bind(authService);

  router.use(requireAuth(isSessionActive));

  router.get('/customer/bootstrap', async (req, res, next) => {
    try {
      const result = await service.getCustomerBootstrap(requirePrincipal(req.principal));
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.get('/customer/catalog', async (req, res, next) => {
    try {
      const parsed = customerCatalogQuerySchema.safeParse(req.query);
      if (!parsed.success) {
        throw new HttpError(
          400,
          'INVALID_REQUEST',
          parsed.error.issues[0]?.message ?? 'Invalid payload.'
        );
      }

      const input = parsed.data;
      const result = await service.getCustomerCatalog(requirePrincipal(req.principal), input);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/customer/retailers/:retailerId/connect', async (req, res, next) => {
    try {
      const result = await service.connectRetailer(
        requirePrincipal(req.principal),
        req.params.retailerId
      );
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/customer/retailers/:retailerId/disconnect', async (req, res, next) => {
    try {
      const result = await service.disconnectRetailer(
        requirePrincipal(req.principal),
        req.params.retailerId
      );
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/customer/checkout', async (req, res, next) => {
    try {
      const parsed = checkoutSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new HttpError(
          400,
          'INVALID_REQUEST',
          parsed.error.issues[0]?.message ?? 'Invalid payload.'
        );
      }

      const input = parsed.data;
      const result = await service.checkout(requirePrincipal(req.principal), input);
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.get('/driver/bootstrap', async (req, res, next) => {
    try {
      const result = await service.getDriverBootstrap(requirePrincipal(req.principal));
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/driver/deliveries/:deliveryId/accept', async (req, res, next) => {
    try {
      const result = await service.acceptDelivery(
        requirePrincipal(req.principal),
        req.params.deliveryId
      );
      res.status(200).json({ job: result });
    } catch (error) {
      next(error);
    }
  });

  router.post('/driver/deliveries/:deliveryId/pickup', async (req, res, next) => {
    try {
      const result = await service.pickupDelivery(
        requirePrincipal(req.principal),
        req.params.deliveryId
      );
      res.status(200).json({ job: result });
    } catch (error) {
      next(error);
    }
  });

  router.post('/driver/deliveries/:deliveryId/complete', async (req, res, next) => {
    try {
      const result = await service.completeDelivery(
        requirePrincipal(req.principal),
        req.params.deliveryId
      );
      res.status(200).json({ job: result });
    } catch (error) {
      next(error);
    }
  });

  return router;
}
