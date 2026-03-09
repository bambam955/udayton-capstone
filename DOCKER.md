# Docker (Backend Services) Setup

Backend and mock services plus the admin dashboard are containerized; Flutter apps run locally with host toolchains.

## Prerequisites

- Docker
- Flutter SDK
- Node.js + npm
- Android Studio + Android SDK/emulator (required for local Flutter Android targets)
  - [Flutter Android setup reference](https://docs.flutter.dev/get-started/install)

## Architecture

`docker compose` now owns backend infrastructure, mock APIs, and the containerized admin dashboard:

- `walmart-mock` from `mocks/docker-compose.yml`
- `target-mock` from `mocks/docker-compose.yml`
- `admin` via profile `admin` from `admin-base/Dockerfile`

Frontend orchestration for Flutter lives in local tooling:

- Flutter web and Android via local `flutter`
- Admin dashboard via local tooling is not used for runtime; it runs via Docker profile `admin`.

## Quick Start

```bash
# One-time setup (deps + backend dependencies)
just setup

# Start services
just up main-web
just up driver-web
just up admin
just up main-android

# Stop backend services
just down
```

`just up` starts backend services first (for app/API dependencies), then:
- runs Flutter app targets locally, or
- runs `admin` in Docker via the `admin` profile.

## `just` command mapping for local execution

From the repo root `justfile`:

- `just up <service>` -> `docker compose up -d` for backend, then local app run:
  - `main-web` / `main` -> `cd apps/main && flutter run -d web-server`
  - `driver-web` / `driver` -> `cd apps/driver && flutter run -d web-server`
  - `main-android` -> `cd apps/main && flutter run`
  - `driver-android` -> `cd apps/driver && flutter run`
  - `admin` -> runs `admin` compose profile container (`docker compose --profile admin up ...`)
- `just test/check/format/deps/clean main|driver` -> `just --justfile apps/justfile ...`
- `just test/check/format/deps/clean admin` -> `just --justfile admin-base/justfile ...`
- `just build main|driver` -> `just --justfile apps/justfile build`
- `just build admin` -> `docker buildx build -f admin-base/Dockerfile`
- `just doctor` -> `just --justfile apps/justfile doctor`
- `just shell` -> local shell

## Environment Variables

- Flutter web
  - `MAIN_WEB_PORT` (default `8080`)
  - `DRIVER_WEB_PORT` (default `8081`)
- Admin
  - `ADMIN_PORT` (default `3001`)

### Example

```bash
MAIN_WEB_PORT=3000 just up main-web
DRIVER_WEB_PORT=3002 just up driver-web
ADMIN_PORT=3010 just up admin
```
