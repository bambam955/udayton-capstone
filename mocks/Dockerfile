# =============================================================================
# Dev: Node + dev tooling
# =============================================================================
FROM node:22-bookworm AS dev

# Install just
RUN npm install -g rust-just

# Install dependencies
WORKDIR /workspace
COPY package*.json ./
RUN npm ci --no-audit --no-fund
