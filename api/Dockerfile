# =============================================================================
# Dev: tsx watch server with full dependencies
# =============================================================================
FROM node:22-bookworm AS dev

WORKDIR /workspace
COPY package*.json ./
RUN npm ci --no-audit --no-fund

COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# =============================================================================
# Prod deps: install all dependencies for typecheck/build
# =============================================================================
FROM node:22-bookworm AS deps

WORKDIR /app
COPY package*.json ./
RUN npm ci --no-audit --no-fund

# =============================================================================
# Prod build: transpile TypeScript to dist/
# =============================================================================
FROM node:22-bookworm AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# =============================================================================
# Prod runtime: minimal, non-root
# =============================================================================
FROM node:22-bookworm-slim AS prod

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder --chown=node:node /app/dist ./dist
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/package*.json ./

USER node

EXPOSE 3000
CMD ["node", "dist/index.js"]
