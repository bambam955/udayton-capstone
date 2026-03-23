# Docker (Backend Services) Setup

Backend and mock services plus the admin dashboard are containerized; Flutter apps run locally with host toolchains.

## Prerequisites

- Docker
- Flutter SDK
- Node.js + npm
- Android Studio + Android SDK/emulator (required for local Flutter Android targets)
  - [Flutter Android setup reference](https://docs.flutter.dev/get-started/install)

## Architecture

The repo-root `docker-compose.yml` is the single runtime compose entrypoint. It includes the db and mock stacks so the top-level view has all backend services:

- `db/docker-compose.yml` for PostgreSQL, Flyway, and the separate local seed loader
- `mocks/docker-compose.yml` for the mock APIs
- `docker-compose.yml` at the repo root for the admin dashboard plus the composed service set

Frontend orchestration for Flutter lives in local tooling:

- Flutter web and Android via local `flutter`
- Admin dashboard via local tooling is not used for runtime; it runs via Docker profile `admin`.

## Quick Start

```bash
# One-time setup (deps + backend dependencies)
just setup

# Start services
just run main-web
just run driver-web
just run admin
just run main-android

# Stop backend services
just down
```

`just run` starts backend services first (for app/API dependencies), then:
- starts the mock APIs in the same root compose project
- runs Flutter app targets locally, or
- runs `admin` in Docker.

To load just the database seed workflow directly:

```bash
just db/seed
```

## Environment Variables

- Flutter web
  - `MAIN_WEB_PORT` (default `8080`)
  - `DRIVER_WEB_PORT` (default `8081`)
- Admin
  - `ADMIN_PORT` (default `3001`)

### Example

```bash
MAIN_WEB_PORT=3000 just run main-web
DRIVER_WEB_PORT=3002 just run driver-web
ADMIN_PORT=3010 just run admin
```
