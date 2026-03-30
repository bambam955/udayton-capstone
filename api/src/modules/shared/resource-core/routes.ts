import { Router } from 'express';

import { HttpError } from '../../../app/errors.js';
import { requireAuth } from '../../../app/middleware/auth.js';
import type { AuthService } from '../../auth/service.js';
import type { ResourceDefinition } from './types.js';
import type { ResourceService } from './service.js';

function requirePrincipal(principal: Express.Request['principal']) {
  if (!principal) {
    throw new HttpError(401, 'UNAUTHORIZED', 'A valid bearer token is required.');
  }

  return principal;
}

function createSingleResourceRouter(
  definition: ResourceDefinition,
  service: ResourceService,
  auth: AuthService
) {
  const router = Router();
  const isSessionActive = auth.isSessionActive.bind(auth);

  router.use(requireAuth(isSessionActive));

  router.get('/', async (req, res, next) => {
    try {
      const principal = requirePrincipal(req.principal);
      const result = await service.list(definition, principal, req.query);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.post('/', async (req, res, next) => {
    try {
      const principal = requirePrincipal(req.principal);
      const result = await service.create(definition, principal, req.body);
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.get('/:id', async (req, res, next) => {
    try {
      const principal = requirePrincipal(req.principal);
      const result = await service.get(definition, principal, req.params.id);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.patch('/:id', async (req, res, next) => {
    try {
      const principal = requirePrincipal(req.principal);
      const result = await service.update(definition, principal, req.params.id, req.body);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.delete('/:id', async (req, res, next) => {
    try {
      const principal = requirePrincipal(req.principal);
      await service.delete(definition, principal, req.params.id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  });

  return router;
}

export function createDomainResourcesRouter(
  service: ResourceService,
  auth: AuthService,
  definitions: ResourceDefinition[]
): Router {
  const router = Router();

  for (const definition of definitions) {
    // Domains own route registration, while the shared core owns the repeated CRUD wiring.
    router.use(`/${definition.path}`, createSingleResourceRouter(definition, service, auth));
  }

  return router;
}
