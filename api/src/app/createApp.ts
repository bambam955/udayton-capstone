import express from 'express';

import { errorHandler } from './middleware/error-handler.js';
import { createAuthRouter } from '../modules/auth/routes.js';
import type { AuthService } from '../modules/auth/service.js';
import { healthRouter } from '../modules/health/routes.js';
import { createOrdersRouter } from '../modules/orders/routes.js';
import type { OrdersService } from '../modules/orders/service.js';

export interface AppServices {
  authService: AuthService;
  ordersService: OrdersService;
}

export function createApp(services: AppServices) {
  const app = express();

  // Global middleware before route registration.
  app.use(express.json());
  app.use('/health', healthRouter);

  // Versioned API surface for mobile apps and admin dashboard.
  app.use('/v1/auth', createAuthRouter(services.authService));
  app.use('/v1/orders', createOrdersRouter(services.ordersService));

  // Terminal error mapper for all downstream handlers.
  app.use(errorHandler);

  return app;
}
