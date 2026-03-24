import { createServer } from 'node:http';

import { createApp } from './app/createApp.js';
import { env } from './config/env.js';
import { KyselyAuthRepository } from './modules/auth/repository.js';
import { AuthService } from './modules/auth/service.js';
import { allResourceDefinitions } from './modules/shared/resource-core/all-definitions.js';
import { PgResourceRepository } from './modules/shared/resource-core/repository.js';
import { ResourceService } from './modules/shared/resource-core/service.js';
import { getDb } from './platform/db/kysely.js';
import { getPool } from './platform/db/pool.js';

// Composition root: wire infrastructure into domain services once at startup.
const db = getDb();

const app = createApp({
  authService: new AuthService(new KyselyAuthRepository(db)),
  resourceService: new ResourceService(new PgResourceRepository(getPool()), allResourceDefinitions)
});

// Keep HTTP server creation explicit so graceful-shutdown hooks can be added later.
const server = createServer(app);

server.listen(env.PORT, () => {
  process.stdout.write(`API listening on port ${env.PORT}\n`);
});
