import path from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { waitForMocks } from './waitForMocks.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default async () => {
  const repoRoot = path.resolve(__dirname, '..', '..', '..');

  console.log('');
  execSync('docker compose up -d', {
    cwd: repoRoot,
    stdio: 'inherit',
  });
  console.log('');

  await waitForMocks();
};
