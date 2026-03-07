const path = require('node:path');
const { execSync } = require('node:child_process');

module.exports = async () => {
  const repoRoot = path.resolve(__dirname, '..', '..', '..');

  console.log('');
  execSync('docker compose down', {
    cwd: repoRoot,
    stdio: 'inherit',
  });
};
