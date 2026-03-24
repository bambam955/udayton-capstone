import express from 'express';

import { errorHandler } from './middleware/error-handler.js';
import { createAdminsRouter } from '../modules/admins/routes.js';
import { createAuthRouter } from '../modules/auth/routes.js';
import type { AuthService } from '../modules/auth/service.js';
import { createCustomersRouter } from '../modules/customers/routes.js';
import { createDeliveriesRouter } from '../modules/deliveries/routes.js';
import { createDriversRouter } from '../modules/drivers/routes.js';
import { healthRouter } from '../modules/health/routes.js';
import { createOrdersRouter } from '../modules/orders/routes.js';
import { createPaymentsRouter } from '../modules/payments/routes.js';
import { createRetailersRouter } from '../modules/retailers/routes.js';
import type { ResourceService } from '../modules/shared/resource-core/service.js';

export interface AppServices {
  authService: AuthService;
  resourceService: ResourceService;
}

export function createApp(services: AppServices) {
  const app = express();

  // Global middleware before route registration.
  app.use(express.json());
  app.use('/health', healthRouter);

  // Versioned API surface for mobile apps and admin dashboard.
  app.use('/v1/auth', createAuthRouter(services.authService));
  app.use('/v1', createAdminsRouter(services.resourceService, services.authService));
  app.use('/v1', createCustomersRouter(services.resourceService, services.authService));
  app.use('/v1', createDriversRouter(services.resourceService, services.authService));
  app.use('/v1', createRetailersRouter(services.resourceService, services.authService));
  app.use('/v1', createOrdersRouter(services.resourceService, services.authService));
  app.use('/v1', createDeliveriesRouter(services.resourceService, services.authService));
  app.use('/v1', createPaymentsRouter(services.resourceService, services.authService));

  // Terminal error mapper for all downstream handlers.
  app.use(errorHandler);

  return app;
}
