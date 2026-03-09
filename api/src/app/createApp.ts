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

  app.use(express.json());
  app.get('/health', healthRouter);

  app.use('/v1/auth', createAuthRouter(services.authService));
  app.use('/v1/customer', createOrdersRouter(services.ordersService));

  app.use(errorHandler);

  return app;
}
