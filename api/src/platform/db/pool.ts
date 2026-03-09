import { Pool } from 'pg';

import { env } from '../../config/env.js';

let pool: Pool | undefined;

export function getPool(): Pool {
  if (!pool) {
    // Singleton pool prevents uncontrolled connection fan-out.
    pool = new Pool({
      connectionString: env.DATABASE_URL,
      max: 10,
      idleTimeoutMillis: 30_000
    });
  }

  return pool;
}

export async function closePool(): Promise<void> {
  if (pool) {
    await pool.end();
    pool = undefined;
  }
}
