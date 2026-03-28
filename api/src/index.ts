import { createServer } from 'node:http';

import { createApp } from './app/createApp.js';
import { env } from './config/env.js';
import { KyselyAuthRepository } from './modules/auth/repository.js';
import { AuthService } from './modules/auth/service.js';
import { KyselyOrdersRepository } from './modules/orders/repository.js';
import { OrdersService } from './modules/orders/service.js';
import { getDb } from './platform/db/kysely.js';

// Composition root: wire infrastructure into domain services once at startup.
const db = getDb();

const app = createApp({
  authService: new AuthService(new KyselyAuthRepository(db)),
  ordersService: new OrdersService(new KyselyOrdersRepository(db))
});

// Keep HTTP server creation explicit so graceful-shutdown hooks can be added later.
const server = createServer(app);

server.listen(env.PORT, () => {
  process.stdout.write(`API listening on port ${env.PORT}\n`);
});
