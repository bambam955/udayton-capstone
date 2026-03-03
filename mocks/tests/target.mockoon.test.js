const fs = require('fs');
const path = require('path');

const targetFile = path.resolve(
  __dirname,
  '..',
  'src',
  'target',
  'target.mockoon.json'
);

function load(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

describe('target mock definition', () => {
  test('file exists and is valid json', () => {
    expect(fs.existsSync(targetFile)).toBe(true);
    expect(() => load(targetFile)).not.toThrow();
  });

  test('target routes are present', () => {
    const env = load(targetFile);
    const actual = env.routes.map((r) => [
      String(r.method).toLowerCase(),
      r.endpoint,
    ]);
    expect(actual).toEqual([
      ['get', 'partner/v1/inventory'],
      ['post', 'partner/v1/orders'],
      ['get', 'partner/v1/orders/:orderNumber/status'],
    ]);
  });

  test('all target routes require x-target-api-key', () => {
    const env = load(targetFile);
    env.routes.forEach((route) => {
      const first = route.responses[0];
      expect(
        first.rules.some(
          (rule) =>
            rule.target === 'header' &&
            rule.modifier === 'x-target-api-key' &&
            rule.value === 'tgt-dev-key'
        )
      ).toBe(true);
    });
  });
});
