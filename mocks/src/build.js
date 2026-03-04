import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Recreate CommonJS-like path globals for an ES module context.
const __filename = fileURLToPath(import.meta.url);
const srcDir = path.dirname(__filename);
const mocksDir = path.resolve(srcDir, '..');
const distDir = path.join(mocksDir, 'dist');

// Read and parse a JSON file, failing fast if the file is missing.
function readJson(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Missing source file: ${filePath}`);
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

// Write pretty-printed JSON and ensure the destination directory exists.
function writeJson(filePath, payload) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(payload, null, 2)}\n`, 'utf8');
}

// Merge two arrays while keeping only the first instance of each uuid.
function mergeUniqueByUuid(a = [], b = []) {
  const out = [...a];
  const seen = new Set(a.map((item) => item && item.uuid).filter(Boolean));

  b.forEach((item) => {
    const uuid = item && item.uuid;
    if (!uuid || !seen.has(uuid)) {
      out.push(item);
      if (uuid) {
        seen.add(uuid);
      }
    }
  });

  return out;
}

// Prevent route UUID collisions across multiple source environments.
function assertNoRouteUuidCollisions(envs) {
  const seen = new Set();

  envs.forEach((env) => {
    (env.routes || []).forEach((route) => {
      if (seen.has(route.uuid)) {
        throw new Error(`Duplicate route uuid found: ${route.uuid}`);
      }
      seen.add(route.uuid);
    });
  });
}

export function buildWalmart() {
  // Build one Walmart Mockoon environment by combining domain-specific sources.
  const walmartDir = path.join(srcDir, 'walmart');
  const sourceFiles = [
    path.join(walmartDir, 'items.mockoon.json'),
    path.join(walmartDir, 'orders.mockoon.json'),
    path.join(walmartDir, 'price.mockoon.json'),
  ];

  const [items, orders, price] = sourceFiles.map(readJson);
  assertNoRouteUuidCollisions([items, orders, price]);

  // Use `items` as the base shape, then merge route-related collections.
  const merged = {
    ...items,
    name: 'Walmart Mock',
    routes: [...(items.routes || []), ...(orders.routes || []), ...(price.routes || [])],
    folders: mergeUniqueByUuid(
      mergeUniqueByUuid(items.folders || [], orders.folders || []),
      price.folders || []
    ),
    data: mergeUniqueByUuid(
      mergeUniqueByUuid(items.data || [], orders.data || []),
      price.data || []
    ),
    headers: [...(items.headers || []), ...(orders.headers || []), ...(price.headers || [])],
    proxyReqHeaders: [
      ...(items.proxyReqHeaders || []),
      ...(orders.proxyReqHeaders || []),
      ...(price.proxyReqHeaders || []),
    ],
    proxyResHeaders: [
      ...(items.proxyResHeaders || []),
      ...(orders.proxyResHeaders || []),
      ...(price.proxyResHeaders || []),
    ],
    port: 3000,
    hostname: '0.0.0.0',
  };

  // Emit the final Walmart artifact into mocks/dist.
  const output = path.join(distDir, 'walmart.mockoon.json');
  writeJson(output, merged);
  return output;
}

export function buildTarget() {
  // Target currently ships as a single source file; copy it to dist as-is.
  const targetSource = path.join(srcDir, 'target', 'target.mockoon.json');
  const target = readJson(targetSource);

  const output = path.join(distDir, 'target.mockoon.json');
  writeJson(output, target);
  return output;
}

function runCli() {
  // CLI entrypoint used by package scripts/automation.
  process.stdout.write('Building mock artifacts...\n');
  buildWalmart();
  buildTarget();
  process.stdout.write(`\x1b[32m✔\x1b[0m Success: all mock artifacts built\n`);
}

runCli();
