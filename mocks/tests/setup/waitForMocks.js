const CHECKS = [
  {
    name: 'walmart',
    url: 'http://localhost:4010/v3/items/feeds',
    headers: { 'x-walmart-api-key': 'wmrt-dev-key' },
  },
  {
    name: 'target',
    url: 'http://localhost:4020/partner/v1/inventory',
    headers: { 'x-target-api-key': 'tgt-dev-key' },
  },
];

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForMocks({ timeoutMs = 30000, intervalMs = 500 } = {}) {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const results = await Promise.all(
      CHECKS.map(async (check) => {
        try {
          const response = await fetch(check.url, { headers: check.headers });
          return response.ok;
        } catch {
          return false;
        }
      })
    );

    if (results.every(Boolean)) {
      return;
    }

    await sleep(intervalMs);
  }

  throw new Error('Timed out waiting for mock services to become ready');
}

export { waitForMocks };
