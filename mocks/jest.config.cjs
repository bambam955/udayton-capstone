/** @type {import('jest').Config} */
const config = {
  testEnvironment: 'node',
  testTimeout: 45000,
  globalSetup: '<rootDir>/tests/setup/globalSetup.cjs',
  globalTeardown: '<rootDir>/tests/setup/globalTeardown.cjs',
  testMatch: '<rootDir>/tests/**/*.test.cjs',
};

module.exports = config;
