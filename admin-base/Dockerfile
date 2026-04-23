# =============================================================================
# Dev: Next.js dev + dev tooling
# =============================================================================
FROM node:22-bookworm AS dev

# Install just
RUN npm install -g rust-just

# Install dependencies
WORKDIR /workspace
COPY package*.json ./
RUN npm ci --no-audit --no-fund

# Run Next.js dev server
EXPOSE 3001
ENV NEXT_TELEMETRY_DISABLED=1
CMD ["npm", "run", "dev", "--", "--hostname", "0.0.0.0", "--port", "3001"]

# =============================================================================
# Build deps: install the full dependency set for the Next.js build stage
# =============================================================================
FROM node:22-bookworm AS deps

WORKDIR /app
COPY package*.json ./
RUN npm ci --no-audit --no-fund

# =============================================================================
# Prod build: compile standalone Next.js output for the runtime image
# =============================================================================
FROM node:22-bookworm AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# =============================================================================
# Prod runtime: Render runs this stage, while local Compose stays on `dev`
# =============================================================================
FROM node:22-bookworm-slim AS prod

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

COPY --from=builder --chown=node:node /app/.next/standalone ./
COPY --from=builder --chown=node:node /app/.next/static ./.next/static

USER node

EXPOSE 3000
CMD ["node", "server.js"]
