import type { Router } from 'express';

import type { AuthService } from '../auth/service.js';
import { createDomainResourcesRouter } from '../shared/resource-core/routes.js';
import type { ResourceService } from '../shared/resource-core/service.js';
import { customerResourceDefinitions } from './definitions.js';

export function createCustomersRouter(service: ResourceService, authService: AuthService): Router {
  return createDomainResourcesRouter(service, authService, customerResourceDefinitions);
}
