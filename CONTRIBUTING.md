# Contributing to BizRush

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Docker Desktop on Mac/Windows, Docker Engine on Linux)
- [`just`](https://github.com/casey/just) command runner
- [`pre-commit`](https://pre-commit.com/) (optional, recommended) — runs formatting and lint checks automatically on each commit

You do **not** need to install Flutter, the Android SDK, Java, or Gradle locally. All build tooling runs inside Docker containers. The root `justfile` wraps everything in `docker compose run`, delegating to `app/justfile` inside the container.

## Getting Started

```bash
# Clone the repository
git clone https://github.com/bizrush-capstone/bizrush.git
cd bizrush

# One-time setup: build images, install deps, verify environment
just setup

# Start web dev server (http://localhost:8080)
just up
```

If `pre-commit` is installed, `just setup` will automatically run `pre-commit install` to set up the Git hooks.

The first build takes ~10-15 minutes to download SDKs. Subsequent builds use Docker cache.

## Common Commands

| Command | Description |
|---------|-------------|
| `just up` | Start web dev server at http://localhost:8080 |
| `just down` | Stop all services |
| `just test` | Run tests |
| `just check` | Static analysis (`flutter analyze`) |
| `just format` | Format code (`dart format`) |
| `just deps` | Install dependencies (`flutter pub get`) |
| `just build` | Build debug APK |
| `just build release` | Build release APK |
| `just run-web` | One-off web run (vs. `just up` which stays attached) |
| `just run-android` | Run on Android emulator (see below) |
| `just doctor` | Run `flutter doctor` in the container |
| `just clean` | Clean build artifacts |
| `just` | List all available commands |

## Running on Android

The Android emulator runs natively on your host machine; Docker handles all Flutter/SDK build tooling. They connect via ADB over TCP.

### Linux / macOS

```bash
# Terminal 1: Start an emulator on the host
just emulator

# Terminal 2: Enable ADB over TCP, then run
just adb-tcp
just run-android
```

On macOS, you may need to install emulator tooling first — see [DOCKER.md](DOCKER.md#macos) for details.

### Windows

1. Install [Android Studio](https://developer.android.com/studio) and create an emulator via Device Manager
2. Start the emulator from Device Manager
3. Enable ADB over TCP:
   ```powershell
   adb tcpip 5555
   ```
4. Run the app (from WSL2 or Git Bash):
   ```bash
   just run-android
   ```

On Windows, `just run-android` uses a local Flutter installation instead of Docker, since nested virtualization prevents Docker from accessing the host emulator. You will need Flutter installed locally for this command only.

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
