import express from 'express';
import request from 'supertest';
import { describe, expect, it } from 'vitest';

import type { Env } from '../../config/env.js';
import { createCorsMiddleware } from '../../app/middleware/cors.js';

function buildCorsTestApp(env: Env) {
  const app = express();

  // Keep the test surface narrow so assertions stay focused on middleware
  // behavior instead of route composition details from the full application.
  app.use(createCorsMiddleware(env));
  app.post('/v1/auth/signup', (_req, res) => {
    res.status(200).json({ ok: true });
  });

  return app;
}

describe('createCorsMiddleware', () => {
  it('allows configured production origins and mirrors requested headers', async () => {
    const env: Env = {
      NODE_ENV: 'production',
      PORT: 3000,
      DATABASE_URL: 'postgres://bizrush:bizrush@localhost:5432/bizrush',
      JWT_SECRET: 'bizrush-local-dev-secret',
      CORS_ALLOWED_ORIGINS: [
        'https://bizrush-beta.onrender.com',
        'https://bizrush-beta-driver.onrender.com'
      ]
    };
    const app = buildCorsTestApp(env);

    const response = await request(app)
      .options('/v1/auth/signup')
      .set('origin', 'https://bizrush-beta.onrender.com')
      .set('access-control-request-method', 'POST')
      .set('access-control-request-headers', 'content-type,x-client');

    expect(response.status).toBe(204);
    expect(response.headers['access-control-allow-origin']).toBe(
      'https://bizrush-beta.onrender.com'
    );
    expect(response.headers['access-control-allow-headers']).toBe('content-type,x-client');
  });

  it('rejects production origins that are not explicitly configured', async () => {
    const env: Env = {
      NODE_ENV: 'production',
      PORT: 3000,
      DATABASE_URL: 'postgres://bizrush:bizrush@localhost:5432/bizrush',
      JWT_SECRET: 'bizrush-local-dev-secret',
      CORS_ALLOWED_ORIGINS: ['https://bizrush-beta.onrender.com']
    };
    const app = buildCorsTestApp(env);

    const response = await request(app)
      .options('/v1/auth/signup')
      .set('origin', 'https://bizrush-beta-driver.onrender.com')
      .set('access-control-request-method', 'POST')
      .set('access-control-request-headers', 'content-type,x-client');

    expect(response.status).toBe(403);
    expect(response.headers['access-control-allow-origin']).toBeUndefined();
  });
});
