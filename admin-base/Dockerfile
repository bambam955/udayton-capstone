FROM node:22-bookworm

# Install just
RUN npm install -g rust-just

WORKDIR /workspace

ENV NEXT_TELEMETRY_DISABLED=1

COPY package*.json ./
RUN npm ci --no-audit --no-fund

EXPOSE 3001

CMD ["npm", "run", "dev", "--", "--hostname", "0.0.0.0", "--port", "3001"]
