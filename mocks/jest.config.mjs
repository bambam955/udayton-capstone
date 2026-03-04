/** @type {import('jest').Config} */
const config = {
  testEnvironment: 'node',
  testTimeout: 45000,
  globalSetup: '<rootDir>/tests/setup/globalSetup.js',
  globalTeardown: '<rootDir>/tests/setup/globalTeardown.js',
  testMatch: '<rootDir>/tests/**/*.test.js',
};

export default config;
