import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { createApp } from '../../app/createApp.js';

const app = createApp({
  authService: {
    login: vi.fn(),
    logout: vi.fn(),
    isSessionActive: vi.fn().mockResolvedValue(true)
  } as never,
  resourceService: {
    list: vi.fn().mockResolvedValue({ data: [] }),
    get: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn()
  } as never
});

describe('createApp', () => {
  it('responds on health endpoint', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });

  it('answers localhost browser preflight requests', async () => {
    const response = await request(app)
      .options('/v1/auth/signup')
      .set('origin', 'http://localhost:8081')
      .set('access-control-request-method', 'POST')
      .set('access-control-request-headers', 'content-type');

    expect(response.status).toBe(204);
    expect(response.headers['access-control-allow-origin']).toBe('http://localhost:8081');
    expect(response.headers['access-control-allow-headers']).toBe('content-type');
  });

  it('rejects disallowed browser preflight requests', async () => {
    const response = await request(app)
      .options('/v1/auth/signup')
      .set('origin', 'https://malicious.example')
      .set('access-control-request-method', 'POST')
      .set('access-control-request-headers', 'content-type');

    expect(response.status).toBe(403);
    expect(response.headers['access-control-allow-origin']).toBeUndefined();
  });
});
