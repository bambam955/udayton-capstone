import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1).default('postgres://bizrush:bizrush@localhost:5432/bizrush'),
  JWT_SECRET: z.string().min(16).default('bizrush-local-dev-secret')
});

export type Env = z.infer<typeof envSchema>;

export const env: Env = envSchema.parse(process.env);
