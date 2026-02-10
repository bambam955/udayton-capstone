# BizRush - project orchestration
# Wraps app commands in Docker; falls back to local tools

set shell := ["bash", "-cu"]

# ---------- Main commands ---------- #

# List available recipes
default:
    @echo "Project recipes:"
    @JUST_LIST_HEADING="" just --list
    @echo ""
    @echo "App recipes (run via Docker):"
    @JUST_LIST_HEADING="" just --justfile app/justfile --list

# Start web development server (http://localhost:8080)
up:
    docker compose up app-web

# Stop all services
down:
    docker compose down

# ---------- App commands (delegated to app/justfile inside container) ---------- #

# Run tests
test: (_docker-just-app "test")

# Analyze code
check: (_docker-just-app "check")

# Format code
format: (_docker-just-app "format")

# Install dependencies
deps: (_docker-just-app "deps")

# Clean build artifacts
clean: (_docker-just-app "clean")

# Run flutter doctor
doctor: (_docker-just-app "doctor")

# ---------- Build/Run commands ---------- #

# Build APK (debug or release)
build target='debug': (_docker-just-app-android "build " + target)

# Run on web (http://localhost:8080)
run-web:
    docker compose run --rm --service-ports app-web

# Run on Android emulator
run-android:
    #!/usr/bin/env bash
    set -euxo pipefail
    case "$(uname -s)" in
        Linux|Darwin)
            docker compose run --rm app-android bash -c \
                "adb connect host.docker.internal:5555 2>/dev/null || true; flutter run"
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            if ! command -v flutter >/dev/null 2>&1; then
                echo "❌ Error: Flutter not found. Install from https://flutter.dev" >&2
                exit 1
            fi
            echo "ℹ️  Windows: Using local Flutter for emulator access" >&2
            cd app && flutter run
            ;;
        *)
            echo "❌ Unknown OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

# ---------- Setup ---------- #

# Verify and set up the development environment
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v docker >/dev/null || { echo "❌ Docker not installed"; exit 1; }
    docker compose build
    docker compose run --rm app-base just deps
    docker compose run --rm app-android just doctor

# Start emulator on host (for connecting from Docker)
emulator:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -s)" in
        Linux|Darwin)
            avd=$(flutter emulators 2>/dev/null | grep '•' | grep -v '^Id' | head -1 | awk '{print $1}')
            if [ -z "$avd" ]; then
                echo "❌ No emulators found. Create one with: flutter emulators --create"
                exit 1
            fi
            echo "Launching $avd..."
            flutter emulators --launch "$avd"
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            echo "Start emulator from Android Studio Device Manager"
            ;;
    esac

# Enable ADB over TCP (run on host before run-android)
adb-tcp:
    adb tcpip 5555

# ---------- Internal ---------- #

# Run an app justfile recipe inside the base container
[private]
_docker-just-app *args:
    docker compose run --rm app-base just {{args}}

# Run an app justfile recipe inside the android container
[private]
_docker-just-app-android *args:
    docker compose run --rm app-android just {{args}}
