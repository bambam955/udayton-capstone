# Docker Development Setup

Develop the Flutter apps and admin dashboard without installing Flutter/Android/Node toolchains on your host. You only need Docker and [just](https://github.com/casey/just).

## Architecture

The project uses Docker Compose profiles for opt-in frontend services:

- Frontend runtime profiles: `main-web`, `driver-web`, `main-android`, `driver-android`, `admin`
- Utility profile: `tools` (`apps-dev-tools`, `apps-android`, `admin-dev-tools`) for one-off commands via `docker compose run`
- Backend services are currently commented out in `docker-compose.yml` (API/DB/mocks are scaffolded but inactive)

`apps/Dockerfile` is multi-stage and shared by both Flutter apps:

| Target | Includes | Used by |
|---|---|---|
| `base` | Ubuntu + mise + Flutter 3.38.10 + just | `apps-dev-tools` |
| `web` | Flutter web precache | `main-web`, `driver-web` |
| `android` | OpenJDK 17 + Android SDK/NDK + Flutter Android precache | `apps-android`, `main-android`, `driver-android` |

`admin-base/Dockerfile` is multi-stage for Next.js admin:

| Target | Includes | Used by |
|---|---|---|
| `dev` | Node 22 + `rust-just` + npm deps + dev server on `3001` | `admin`, `admin-dev-tools` |
| `prod` | Slim Node runtime with standalone Next.js output on `3000` | `just build admin` image build |

First build can take 10-15 minutes due to Flutter/Android SDK downloads; subsequent builds reuse cache and named volumes.

## Quick Start

```bash
# One-time setup: build images and install dependencies
just setup

# Start one or more frontend services
just up main-web
just up main-web driver-web
just up driver-android admin

# Stop all services
just down

# Run quality commands (all components by default)
just test
just check
just format

# Scope to a component
just test main
just check driver
just format admin

# Install deps
just deps
just deps main

# Build artifacts
just build main --release
just build driver
just build admin

# Shell and doctor
just shell
just doctor
```

## Services and Ports

| Compose Service | Profile | Default Host Port | Notes |
|---|---|---|---|
| `main-web` | `main-web` | `8080` | Flutter web server (`/workspace/main`) |
| `driver-web` | `driver-web` | `8081` | Flutter web server (`/workspace/driver`) |
| `main-android` | `main-android` | N/A | `flutter run` in Docker using host ADB bridge |
| `driver-android` | `driver-android` | N/A | `flutter run` in Docker using host ADB bridge |
| `admin` | `admin` | `3001` | Next.js dev server |

The `just up ...` recipe attaches to the first selected service for interactive stdin (for example hot reload keys).

## `just` Command Mapping

From the repo root `justfile`:

- `just test/check/format/deps/clean main|driver` -> `docker compose run --rm apps-dev-tools just <recipe> <app>`
- `just test/check/format/deps/clean admin` -> `docker compose run --rm admin-dev-tools just <recipe>`
- `just build main|driver ...` -> `docker compose run --rm apps-android just build <app> ...`
- `just build admin` -> `docker buildx build --tag bizrush/admin:latest --target prod -f admin-base/Dockerfile admin-base/`
- `just doctor` -> `docker compose run --rm apps-android just doctor`
- `just shell` -> `docker compose run --rm apps-dev-tools bash`

## Android Emulator Notes

For Android profiles, `just up ...-android` runs `just android-preflight`, which comes out to:

```bash
adb start-server
adb devices
```

Android containers connect to host ADB via:

```bash
ADB_SERVER_SOCKET=tcp:${ADB_HOST:-host.docker.internal}:${ADB_PORT:-5037}
```

Start an emulator/device on the host first:

```bash
just emulator
just up main-android
```

If multiple devices are connected, set `ANDROID_SERIAL=<device-id>` before `just up ...-android`.
If no emulator exists, create one with `flutter emulators --create` (from a host with Flutter installed).

## Environment Variables

Override default ports as needed:

```bash
MAIN_WEB_PORT=3000 just up main-web
DRIVER_WEB_PORT=3002 just up driver-web
ADMIN_PORT=3010 just up admin

# Android host-ADB bridge overrides (optional)
ADB_HOST=host.docker.internal ADB_PORT=5037 just up main-android
ANDROID_SERIAL=emulator-5554 just up main-android
```

## Troubleshooting

- No Android device found: run `adb devices`, then restart ADB and reconnect emulator.
- Linux KVM denied: `sudo usermod -aG kvm $USER`, then log out/in.
- Admin deps issues: remove `admin-node-modules` volume and rerun `just deps admin`.
