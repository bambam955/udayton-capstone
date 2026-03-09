FROM node:20-bookworm AS base
WORKDIR /workspace

FROM base AS deps
COPY package*.json ./
RUN npm ci

FROM deps AS dev
COPY . .
CMD ["npm", "run", "dev"]

FROM deps AS build
COPY . .
RUN npm run build

FROM node:20-bookworm-slim AS prod
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /workspace/node_modules ./node_modules
COPY --from=build /workspace/dist ./dist
COPY package*.json ./
CMD ["node", "dist/index.js"]
