# Contributing to BizRush

## Prerequisites

### Dev Tooling

- [Docker](https://docs.docker.com/get-docker/) (Docker Desktop on Mac/Windows, Docker Engine on Linux)
- [`just`](https://github.com/casey/just) command runner
- [`pre-commit`](https://pre-commit.com/) (optional, recommended) — runs formatting and lint checks automatically on each commit

### Project Tech Stack

- Flutter
- Android Studio and Android emulator

You do **not** need to install the Android SDK, Java, or Gradle locally. All build tooling runs inside Docker containers for a consistent build environment. The root `justfile` wraps everything in `docker compose run`, delegating to `app/justfile` inside the container.

## Getting Started

```bash
# Clone the repository
git clone https://github.com/bizrush-capstone/bizrush.git
cd bizrush

# One-time setup: build images, install deps, verify environment
just setup

# Start web dev server (http://localhost:8080)
just up main-web
```

If `pre-commit` is installed, `just setup` will automatically run `pre-commit install` to set up the Git hooks.

The first build takes ~10-15 minutes to download SDKs. Subsequent builds use Docker cache.

## Common Commands

| Command | Description |
|---------|-------------|
| `just up <services>` | Start backend + selected frontend services |
| `just down` | Stop all services |
| `just test <components>` | Run tests |
| `just check <components>` | Static source code analysis and linting |
| `just format <components>` | Format code |
| `just deps <components>` | Install dependencies (`flutter pub get`) |
| `just build <component> [args]` | Build a deployable version of the specified component |
| `just doctor` | Run `flutter doctor` in the dev container |
| `just clean <components>` | Clean build artifacts |
| `just` | List all available commands |

## Running on Android

The Android emulator runs natively on your host machine; Docker handles all Flutter/SDK build tooling. They connect via ADB over TCP.

### Linux / macOS

```bash
# Terminal 1: Start an emulator on the host
just --justfile apps/justfile emulator

# Terminal 2: run an app on the emulator
just up main-android
just up driver-android
```

On macOS, you may need to install emulator tooling first — see [DOCKER.md](DOCKER.md#macos) for details.

### Windows

1. Install [Android Studio](https://developer.android.com/studio) and create an emulator via Device Manager
2. Start the emulator from Device Manager
3. Run the app (from WSL2 or Git Bash):
   ```bash
   just up main-android
   ```

## Testing

```bash
just test
```

## Code Quality

- Run `just check` before submitting changes
- Run `just format` to auto-format code
- Follow [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)

## Submitting Changes

1. Create a feature branch
2. Make your changes
3. Run `just check` and `just test` to verify
4. Write clear commit messages
5. Submit a pull request with a description of changes
