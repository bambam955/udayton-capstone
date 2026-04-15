import { Router } from 'express';
import { z } from 'zod';

import { HttpError } from '../../app/errors.js';
import { requireAuth } from '../../app/middleware/auth.js';
import type { AuthPrincipal } from '../../app/types.js';
import type { AuthService } from '../auth/service.js';
import type { MobileServiceContract } from './types.js';

// The catalog endpoint uses query-string filters so the Flutter clients can
// update categories/search text without changing the route shape.
const customerCatalogQuerySchema = z.object({
  retailerLocationId: z.string().uuid(),
  category: z.string().min(1).optional(),
  query: z.string().min(1).optional()
});

// Checkout accepts a compact payload because the cart contents already live in
// server-side resource tables. The mobile client only needs to identify the
// cart, delivery address, and any optional presentation details.
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
  // `requireAuth` expects a simple session validator callback, so bind the
  // auth service method once and let every mobile route share the same guard.
  const isSessionActive = authService.isSessionActive.bind(authService);

  router.use(requireAuth(isSessionActive));

  router.get('/customer/bootstrap', async (req, res, next) => {
    try {
      // Bootstrap intentionally aggregates the first screen's worth of customer
      // state so the app can render stores, cart state, orders, and support
      // without a burst of sequential startup calls.
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
      // Keep filtering in the service/repository so the route remains a thin
      // transport layer and the same catalog rules can be reused in tests.
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
      // Checkout creates new order/payment/delivery rows, so a `201` makes the
      // write semantics explicit to mobile clients and tests.
      const result = await service.checkout(requirePrincipal(req.principal), input);
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/customer/orders/:orderId/cancel', async (req, res, next) => {
    try {
      const result = await service.cancelOrder(
        requirePrincipal(req.principal),
        req.params.orderId
      );
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.get('/driver/bootstrap', async (req, res, next) => {
    try {
      // Driver bootstrap mirrors the customer bootstrap idea: ship enough live
      // state for the shell to render nearby offers, active work, earnings,
      // and support without building that view from ad hoc calls.
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
      // Driver actions return the refreshed job payload immediately so the
      // client can update route guidance and tab state without waiting for a
      // second read.
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
