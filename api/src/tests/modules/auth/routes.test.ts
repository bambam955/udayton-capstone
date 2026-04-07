import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../../../app/createApp.js';
import { makeBearer } from '../../support/resource-test-helpers.js';

function makeApp() {
  return createApp({
    authService: {
      signup: async (input: unknown) => ({
        accessToken: 'signed-signup-token',
        expiresAt: new Date('2026-03-24T12:00:00.000Z'),
        user: {
          id: (input as { role?: string }).role === 'driver' ? 'driver-2' : 'cust-2',
          role: (input as { role?: string }).role ?? 'customer',
          email: (input as { email: string }).email
        }
      }),
      login: async (input: unknown) => ({
        accessToken: 'signed-token',
        expiresAt: new Date('2026-03-24T12:00:00.000Z'),
        user: {
          id: 'cust-1',
          role: 'customer',
          email: (input as { email: string }).email
        }
      }),
      logout: async () => undefined,
      isSessionActive: async () => true
    } as never,
    resourceService: {
      list: async () => ({ data: [] }),
      get: async () => ({ data: {} }),
      create: async () => ({ data: {} }),
      update: async () => ({ data: {} }),
      delete: async () => undefined
    } as never
  });
}

describe('auth routes', () => {
  it('returns signup results for valid payloads', async () => {
    const response = await request(makeApp()).post('/v1/auth/signup').send({
      role: 'customer',
      email: 'newcustomer@example.com',
      password: 'secret',
      fullName: 'New Customer'
    });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      accessToken: 'signed-signup-token',
      user: {
        email: 'newcustomer@example.com',
        role: 'customer'
      }
    });
  });

  it('accepts driver signup payloads', async () => {
    const response = await request(makeApp()).post('/v1/auth/signup').send({
      role: 'driver',
      email: 'newdriver@example.com',
      password: 'secret',
      fullName: 'New Driver',
      phone: '555-202-0006'
    });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      accessToken: 'signed-signup-token',
      user: {
        email: 'newdriver@example.com',
        role: 'driver'
      }
    });
  });

  it('returns 400 for invalid login payloads', async () => {
    const response = await request(makeApp()).post('/v1/auth/login').send({
      role: 'customer',
      email: 'not-an-email'
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ error: 'INVALID_REQUEST' });
  });

  it('returns login results for valid payloads', async () => {
    const response = await request(makeApp()).post('/v1/auth/login').send({
      role: 'customer',
      email: 'customer@example.com',
      password: 'secret'
    });

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      accessToken: 'signed-token',
      user: {
        email: 'customer@example.com',
        role: 'customer'
      }
    });
  });

  it('returns the decoded principal on /me', async () => {
    const response = await request(makeApp())
      .get('/v1/auth/me')
      .set('authorization', makeBearer('cust-1', 'customer'));

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      principal: {
        userId: 'cust-1',
        role: 'customer'
      }
    });
  });
});
