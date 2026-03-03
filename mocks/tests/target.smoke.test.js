describe('target smoke tests', () => {
  test('order create returns success when authorized', async () => {
    const response = await fetch('http://localhost:4020/partner/v1/orders', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-target-api-key': 'tgt-dev-key',
      },
      body: JSON.stringify({
        buyer: { name: 'BizRush' },
        items: [{ tcin: '10000001', qty: 2 }],
      }),
    });

    expect(response.ok).toBe(true);
  });

  test('order status returns success when authorized', async () => {
    const response = await fetch(
      'http://localhost:4020/partner/v1/orders/TGT-1234/status',
      {
        headers: { 'x-target-api-key': 'tgt-dev-key' },
      }
    );

    expect(response.ok).toBe(true);
  });
});
