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
});
