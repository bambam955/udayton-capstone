# =============================================================================
# Dev: local Compose target with tsx watch and full tooling
# =============================================================================
FROM node:22-bookworm AS dev

WORKDIR /workspace
COPY api/package*.json ./
RUN npm ci --no-audit --no-fund

COPY api/ ./
EXPOSE 3000
CMD ["npm", "run", "dev"]

# =============================================================================
# Build deps: install dev dependencies for lint/typecheck/build stages
# =============================================================================
FROM node:22-bookworm AS build-deps

WORKDIR /app
COPY api/package*.json ./
RUN npm ci --no-audit --no-fund

# =============================================================================
# Prod build: compile app-only TypeScript output for the runtime image
# =============================================================================
FROM node:22-bookworm AS builder

WORKDIR /app
COPY --from=build-deps /app/node_modules ./node_modules
COPY api/ ./
RUN npm run build

# =============================================================================
# Prod deps: install runtime-only dependencies for the Render image
# =============================================================================
FROM node:22-bookworm AS prod-deps

WORKDIR /app
COPY api/package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund && npm cache clean --force

# =============================================================================
# Prod runtime: Render runs this stage, while local Compose stays on `dev`
# =============================================================================
FROM node:22-bookworm-slim AS prod

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tar \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder --chown=node:node /app/dist ./dist
COPY --from=prod-deps --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/package*.json ./
COPY --chown=node:node db ./db
COPY --chown=node:node scripts/render ./scripts/render

RUN chmod +x ./scripts/render/install_flyway.sh ./scripts/render/start_api_container.sh \
    && chown -R node:node /app

USER node

EXPOSE 3000
CMD ["./scripts/render/start_api_container.sh"]
