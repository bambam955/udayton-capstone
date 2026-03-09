import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import { createApp } from '../../app/createApp.js';

const app = createApp({
  authService: {
    login: vi.fn(),
    logout: vi.fn()
  } as never,
  ordersService: {
    listMyOrders: vi.fn().mockResolvedValue([])
  } as never
});

describe('createApp', () => {
  it('responds on health endpoint', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });
});
