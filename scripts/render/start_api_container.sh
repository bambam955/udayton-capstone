#!/usr/bin/env bash
set -euo pipefail

# Keep the Docker runtime startup path aligned with the previous Render native
# commands: install Flyway if needed, run idempotent migrations, and only seed
# demo data for beta deployments.
seed_args=()
if [ "${BIZRUSH_INCLUDE_BETA_SEED:-false}" = "true" ]; then
    seed_args+=(--include-beta-seed)
fi

./scripts/render/install_flyway.sh
node ./scripts/render/run_api_migrations.mjs "${seed_args[@]}"
exec node ./dist/index.js
