describe('walmart smoke tests', () => {
  test('item feeds endpoint returns success when authorized', async () => {
    const response = await fetch('http://localhost:4010/v3/items/feeds', {
      headers: { 'x-walmart-api-key': 'wmrt-dev-key' },
    });

    expect(response.ok).toBe(true);
  });

  test('orders endpoint returns 401 when unauthorized', async () => {
    const response = await fetch('http://localhost:4010/v3/orders');

    expect(response.status).toBe(401);
  });

  test('pricing feed update returns success when authorized', async () => {
    const response = await fetch('http://localhost:4010/v3/price/feeds', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-walmart-api-key': 'wmrt-dev-key',
      },
      body: '{}',
    });

    expect(response.ok).toBe(true);
  });
});
