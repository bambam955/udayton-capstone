# Docker Development Setup

Develop the Flutter apps without installing Flutter, Android SDK, Java, or Gradle locally. All you need is Docker and [just](https://github.com/casey/just).

## Architecture

The project uses Docker Compose **profiles** to manage services:

- **Backend services** (API, DB, Mockoon mocks) have no profile — they always start with any `just up` command.
- **Frontend services** are opt-in via profiles: `main-web`, `driver-web`, `main-android`, `driver-android`, `admin`.
- **Utility services** (`apps-dev-tools`, `apps-android`) are used only via `docker compose run` for one-off commands like test/build.

Both Flutter apps share a single multi-stage Dockerfile (`apps/Dockerfile`):

| Dockerfile Target | What it adds | Used by |
|-------------------|--------------|---------|
| `base` | Flutter + just via mise | apps-dev-tools, devcontainer |
| `web` | Web build toolchain | main-web, driver-web |
| `android` | JDK + Android SDK | apps-android, main-android, driver-android |

First build takes ~10-15 minutes to download SDKs. Subsequent builds use cache.

## Quick Start

```bash
# One-time setup: build images, install deps
just setup

# Start backend + main app web server (http://localhost:8080)
just up main-web

# Start backend + both web apps
just up main-web driver-web

# Start backend + driver on emulator + admin dashboard
just up driver-android admin

# Run tests / analyze / format (all components, or specify)
just test
just test main
just check driver
just format main driver

# Build APKs
just build main
just build driver --release

# Interactive shell inside the container
just shell

# See all available commands
just
```

## Profiles Reference

| Profile | Description | Default Port |
|---------|-------------|--------------|
| `main-web` | Main app web server | http://localhost:8080 |
| `driver-web` | Driver app web server | http://localhost:8081 |
| `main-android` | Main app on Android emulator | — |
| `driver-android` | Driver app on Android emulator | — |
| `admin` | Admin dashboard | http://localhost:3001 |

## Emulator Setup by Platform

### Linux

Run emulator on the host, connect from Docker:

```bash
# Start emulator, then run (ADB TCP is enabled automatically)
just emulator
just up main-android
```

### macOS

```bash
# One-time: Install emulator
brew install --cask android-commandlinetools
sdkmanager "emulator" "platform-tools" "system-images;android-36;google_apis;arm64-v8a"
avdmanager create avd -n dev -k "system-images;android-36;google_apis;arm64-v8a"

# Terminal 1: Start emulator
just emulator

# Terminal 2: Run (ADB TCP is enabled automatically)
just up main-android
```

### Windows

1. Install Android Studio → Device Manager → Create Pixel 6 (API 36)
2. Start emulator from Device Manager

```bash
# WSL2/Git Bash (ADB TCP is enabled automatically):
just up main-android
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `just setup` | Build all images, install deps |
| `just up <service>...` | Start backend + selected frontend services |
| `just down` | Stop all services |
| `just test [components...]` | Run tests (defaults to all) |
| `just check [components...]` | Static analysis (defaults to all) |
| `just format [components...]` | Format code (defaults to all) |
| `just deps [components...]` | Install dependencies (defaults to all) |
| `just build <component> [args...]` | Build a component |
| `just shell` | Interactive shell in container |
| `just doctor` | Run flutter doctor |

## Port Configuration

Default ports can be overridden with environment variables:

```bash
MAIN_WEB_PORT=3000 just up main-web
DRIVER_WEB_PORT=3001 just up driver-web
```

## Troubleshooting

**No devices:** Run `adb devices` to verify. Try `adb kill-server && adb connect <host>:5555`

**KVM denied (Linux):** `sudo usermod -aG kvm $USER` then log out/in

**Windows firewall:** Allow port 5555 for ADB
