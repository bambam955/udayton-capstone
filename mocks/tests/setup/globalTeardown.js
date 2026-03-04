import path from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default async () => {
  const repoRoot = path.resolve(__dirname, '..', '..', '..');

  console.log('');
  execSync('docker compose down', {
    cwd: repoRoot,
    stdio: 'inherit',
  });
};
