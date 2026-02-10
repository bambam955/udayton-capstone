# Docker Development Setup

Develop the Flutter app without installing Flutter, Android SDK, Java, or Gradle locally. All you need is Docker and [just](https://github.com/casey/just).

## Architecture

The Dockerfile (`app/Dockerfile`) uses multi-stage builds to create three images:

| Image | Target | What it adds | Used for |
|-------|--------|--------------|----------|
| **app-base** | `base` | Flutter + just via mise | test, check, format, deps |
| **app-web** | `web` | Web build toolchain | `just up`, `just run-web` |
| **app-android** | `android` | JDK + Android SDK | `just build`, `just run-android` |

The root `justfile` wraps all commands in `docker compose run`, delegating to `app/justfile` inside the container. You never need to think about Docker when running day-to-day commands.

First build takes ~10-15 minutes to download SDKs. Subsequent builds use cache.

## Quick Start

```bash
# One-time setup: build images, install deps, verify environment
just setup

# Start web dev server (http://localhost:8080)
just up

# Run tests / analyze / format
just test
just check
just format

# Interactive shell inside the container
just shell

# See all available commands
just
```

## Emulator Setup by Platform

### Linux

Run emulator on the host, connect from Docker:

```bash
# Start emulator
just emulator

# Enable ADB over TCP, then run
just adb-tcp
just run-android
```

### macOS

```bash
# One-time: Install emulator
brew install --cask android-commandlinetools
sdkmanager "emulator" "platform-tools" "system-images;android-36;google_apis;arm64-v8a"
avdmanager create avd -n dev -k "system-images;android-36;google_apis;arm64-v8a"

# Terminal 1: Start emulator
just emulator

# Terminal 2: Enable TCP and run
just adb-tcp
just run-android
```

### Windows

1. Install Android Studio → Device Manager → Create Pixel 6 (API 36)
2. Start emulator from Device Manager

```powershell
# PowerShell: Enable ADB over TCP
adb tcpip 5555
```

```bash
# WSL2/Git Bash:
just run-android
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `just setup` | Build images, install deps, verify environment |
| `just up` | Start web dev server (http://localhost:8080) |
| `just down` | Stop all services |
| `just test` | Run tests |
| `just check` | Static analysis |
| `just format` | Format code |
| `just deps` | Install dependencies |
| `just build` | Build debug APK |
| `just build release` | Build release APK |
| `just run-android` | Run on Android emulator |
| `just shell` | Interactive shell in container |
| `just doctor` | Run flutter doctor |

## Troubleshooting

**No devices:** Run `adb devices` to verify. Try `adb kill-server && adb connect <host>:5555`

**KVM denied (Linux):** `sudo usermod -aG kvm $USER` then log out/in

**Windows firewall:** Allow port 5555 for ADB
