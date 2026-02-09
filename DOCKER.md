# Docker Development Setup

Develop the Flutter app without installing Flutter, Android SDK, Java, or Gradle locally.

**Image sizes:** ~5.6GB (flutter), ~7GB (flutter-emulator)

First build takes ~10-15 minutes to download SDKs. Subsequent builds use cache.

## Quick Start

```bash
# Build the image
docker compose build flutter

# Interactive shell
docker compose run --rm flutter

# Run tests
docker compose run --rm flutter flutter test

# Build APK
docker compose run --rm flutter flutter build apk

# Run web (http://localhost:8080)
docker compose run --rm --service-ports flutter \
  flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

---

## Emulator Setup by Platform

### Linux (Full Docker Experience)

Linux can run the emulator inside Docker with KVM passthrough:

```bash
# Ensure KVM access
sudo usermod -aG kvm $USER && newgrp kvm

# Build and run with emulator
docker compose build flutter-emulator
docker compose run --rm --service-ports flutter-emulator

# Inside container - start headless emulator:
emulator -avd default_avd -no-window -no-audio -gpu swiftshader_indirect &
adb wait-for-device
flutter run
```

### macOS

Run emulator on Mac, connect from Docker:

```bash
# One-time: Install emulator
brew install --cask android-commandlinetools
sdkmanager "emulator" "platform-tools" "system-images;android-36;google_apis;arm64-v8a"
avdmanager create avd -n dev -k "system-images;android-36;google_apis;arm64-v8a"

# Terminal 1: Start emulator
emulator -avd dev

# Terminal 2: Enable TCP and run Flutter
adb tcpip 5555
docker compose run --rm flutter bash -c "adb connect host.docker.internal:5555 && flutter run"
```

### Windows

Run emulator on Windows, connect from Docker:

1. Install Android Studio → Device Manager → Create Pixel 6 (API 36)
2. Start emulator from Device Manager

```powershell
# PowerShell: Enable ADB over TCP
adb tcpip 5555
```

```bash
# WSL2/Git Bash: Run Flutter in Docker
docker compose run --rm flutter bash -c "adb connect host.docker.internal:5555 && flutter run"
```

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0` | Run on web |
| `flutter run` | Run on connected device |
| `flutter test` | Run tests |
| `flutter build apk` | Build release APK |
| `flutter analyze` | Static analysis |
| `adb connect <host>:5555` | Connect to remote emulator |

## Troubleshooting

**No devices:** Run `adb devices` to verify. Try `adb kill-server && adb connect <host>:5555`

**KVM denied:** `sudo usermod -aG kvm $USER` then log out/in

**Windows firewall:** Allow port 5555 for ADB
