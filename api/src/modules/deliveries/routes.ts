import type { Router } from 'express';

import type { AuthService } from '../auth/service.js';
import { createDomainResourcesRouter } from '../shared/resource-core/routes.js';
import type { ResourceService } from '../shared/resource-core/service.js';
import { deliveryResourceDefinitions } from './definitions.js';

export function createDeliveriesRouter(
  service: ResourceService,
  authService: AuthService
): Router {
  return createDomainResourcesRouter(service, authService, deliveryResourceDefinitions);
}
