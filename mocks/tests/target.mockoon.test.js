import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const targetFile = path.resolve(
  __dirname,
  '..',
  'src',
  'target',
  'target.mockoon.json'
);
const targetDistFile = path.resolve(
  __dirname,
  '..',
  'dist',
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

  test('generated target file includes expected routes', () => {
    expect(fs.existsSync(targetDistFile)).toBe(true);
    const env = load(targetDistFile);
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
