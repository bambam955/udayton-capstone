const path = require('path');
const { execSync } = require('child_process');

module.exports = async () => {
  const repoRoot = path.resolve(__dirname, '..', '..', '..');

  execSync('docker compose down', {
    cwd: repoRoot,
    stdio: 'inherit',
  });
};
