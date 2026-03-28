import { Kysely, PostgresDialect } from 'kysely';

import type { Database } from './types.js';
import { getPool } from './pool.js';

let db: Kysely<Database> | undefined;

export function getDb(): Kysely<Database> {
  if (!db) {
    // Reuse one typed Kysely instance across repositories.
    db = new Kysely<Database>({
      dialect: new PostgresDialect({
        pool: getPool()
      })
    });
  }

  return db;
}

export async function closeDb(): Promise<void> {
  if (db) {
    await db.destroy();
    db = undefined;
  }
}
