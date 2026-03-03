const path = require('path');
const { execSync } = require('child_process');
const { waitForMocks } = require('./waitForMocks');

module.exports = async () => {
  // console.log('======================== STARTING GLOBAL SETUP PROCESS');

  const repoRoot = path.resolve(__dirname, '..', '..', '..');

  execSync('docker compose up -d', {
    cwd: repoRoot,
    stdio: 'inherit',
  });

  await waitForMocks();

  // console.log('======================== ALL MOCKS UP AND RUNNING');
};
