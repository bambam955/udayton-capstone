const path = require('node:path');
const { execSync } = require('node:child_process');
const { waitForMocks } = require('./waitForMocks.cjs');

module.exports = async () => {
  const repoRoot = path.resolve(__dirname, '..', '..', '..');

  console.log('');
  execSync('docker compose up -d', {
    cwd: repoRoot,
    stdio: 'inherit',
  });
  console.log('');

  await waitForMocks();
};
