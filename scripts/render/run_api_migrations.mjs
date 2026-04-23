#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const DEFAULT_FLYWAY_VERSION = "12.4.0";
const BETA_SEED_PASSWORD_ENV = "BETA_ADMIN_SEED_PASSWORD";

function main() {
  const includeBetaSeed = process.argv.includes("--include-beta-seed");
  const repoRoot = process.cwd();
  const flywayVersion = process.env.FLYWAY_VERSION ?? DEFAULT_FLYWAY_VERSION;
  const flywayBinary = resolve(repoRoot, ".render-tools", `flyway-${flywayVersion}`, "flyway");

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error("DATABASE_URL is required to run Flyway migrations.");
  }

  // Render exposes a standard PostgreSQL URL. Flyway wants a JDBC URL and
  // separate credentials, so we normalize it once in code instead of relying on
  // brittle shell parsing in the deploy hook.
  const parsedUrl = new URL(databaseUrl);
  const jdbcUrl = `jdbc:postgresql://${parsedUrl.hostname}:${parsedUrl.port || "5432"}${parsedUrl.pathname}`;
  const username = decodeURIComponent(parsedUrl.username);
  const password = decodeURIComponent(parsedUrl.password);

  if (!username || !password) {
    throw new Error("DATABASE_URL must include both a username and password.");
  }

  const locations = [resolve(repoRoot, "db", "migrations")];
  let tempDir;

  try {
    if (includeBetaSeed) {
      const betaSeedPassword = process.env[BETA_SEED_PASSWORD_ENV];
      if (!betaSeedPassword) {
        throw new Error(`${BETA_SEED_PASSWORD_ENV} is required when seeding beta demo data.`);
      }

      tempDir = mkdtempSync(join(tmpdir(), "bizrush-render-beta-seed-"));
      const generatedSeedPath = join(tempDir, "R__beta_demo_seed.sql");
      const localSeedPath = resolve(repoRoot, "db", "seed", "R__local_seed_data.sql");

      // Keep the checked-in local seed as the single source of truth. For
      // Render beta deploys we copy it to a temporary Flyway location and swap
      // the psql-only admin password token for a Flyway placeholder.
      const betaSeedSql = readFileSync(localSeedPath, "utf8").replace(
        ":'admin_seed_password'",
        "'${adminSeedPassword}'"
      );

      writeFileSync(generatedSeedPath, betaSeedSql);
      locations.push(tempDir);
    }

    const flywayArgs = [
      `-url=${jdbcUrl}`,
      `-user=${username}`,
      `-password=${password}`,
      "-connectRetries=60",
      `-locations=${locations.map((location) => `filesystem:${location}`).join(",")}`,
    ];

    if (includeBetaSeed) {
      flywayArgs.push(`-placeholders.adminSeedPassword=${process.env[BETA_SEED_PASSWORD_ENV]}`);
    }

    flywayArgs.push("migrate");

    const result = spawnSync(flywayBinary, flywayArgs, {
      cwd: repoRoot,
      stdio: "inherit",
    });

    if (result.error) {
      throw result.error;
    }

    if (result.status !== 0) {
      throw new Error(`Flyway exited with status ${result.status ?? "unknown"}.`);
    }
  } finally {
    if (tempDir) {
      rmSync(tempDir, { force: true, recursive: true });
    }
  }
}

try {
  main();
} catch (error) {
  // Keep deploy logs explicit so a failed migration is immediately actionable in
  // Render without requiring a second look through wrapper code.
  const message = error instanceof Error ? error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exit(1);
}
