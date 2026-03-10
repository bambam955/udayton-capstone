import dotenv from 'dotenv';
import { z } from 'zod';

// Load .env before we read process.env so local development works out-of-the-box.
dotenv.config();

// Fail fast on misconfiguration so bad env never reaches runtime paths.
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1).default('postgres://bizrush:bizrush@localhost:5432/bizrush'),
  JWT_SECRET: z.string().min(16).default('bizrush-local-dev-secret')
});

export type Env = z.infer<typeof envSchema>;

// Parse once and export a typed env object for the rest of the app.
export const env: Env = envSchema.parse(process.env);
