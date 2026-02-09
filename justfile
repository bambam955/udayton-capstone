# Cross-platform Flutter development
# Prefers Docker Compose, falls back to local tools with warning

set shell := ["bash", "-cu"]

# ---------- Main commands ---------- #

# List available recipes
default:
    @echo "Top-level recipes:"
    @JUST_LIST_HEADING="" just --list
    @echo "App recipes:"
    @cd app/ && JUST_LIST_HEADING="" just --list --list-prefix "    app/"

# Start web development server (http://localhost:8080)
up:
    docker compose up app-web

# Stop all services
down:
    docker compose down

# ---------- Build/Test commands ---------- #

# Build APK (debug or release)
build target='debug': (_flutter-cmd "flutter build apk --" + target)

# ---------- Run commands ---------- #

# Run on web (http://localhost:8080)
run-web:
    docker compose run --rm --service-ports app-web

# Run on Android emulator
run-android:
    #!/usr/bin/env bash
    case "$(uname -s)" in
        Linux|Darwin)
            # Linux/Mac: use Docker, connect to host emulator
            docker compose run --rm app-android bash -c \
                "adb connect host.docker.internal:5555 2>/dev/null || true; flutter run"
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            # Windows: use local Flutter (Docker can't reach Windows emulator easily)
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

# Build Docker images
docker-build:
    docker compose build

# Start emulator on host (for connecting from Docker)
emulator:
    #!/usr/bin/env bash
    case "$(uname -s)" in
        Darwin)
            emulator -avd dev 2>/dev/null || echo "Create AVD: avdmanager create avd -n dev -k 'system-images;android-36;google_apis;arm64-v8a'"
            ;;
        Linux)
            emulator -avd default_avd 2>/dev/null || flutter emulators --launch Medium_Phone_API_36.1 2>/dev/null || echo "No emulator found"
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            echo "Start emulator from Android Studio Device Manager"
            ;;
    esac

# Enable ADB over TCP (run on host before run-android)
adb-tcp:
    adb tcpip 5555

# ---------- Internal ---------- #

# Run a flutter command, preferring compose (uses android image for full SDK)
[private]
_flutter-cmd *args:
    #!/usr/bin/env bash
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        # docker compose run --rm app-web bash -c "flutter pub get --offline 2>/dev/null || flutter pub get && {{ args }}"
        docker compose run --rm app-web bash -c "flutter pub get && {{ args }}"
    elif command -v flutter >/dev/null 2>&1; then
        echo "⚠️  Warning: Docker not available, using local Flutter" >&2
        cd app && flutter pub get --offline 2>/dev/null || flutter pub get
        cd app && {{ args }}
    else
        echo "❌ Error: Neither Docker Compose nor Flutter found" >&2
        echo "   Install Docker: https://docs.docker.com/get-docker/" >&2
        echo "   Or Flutter: https://flutter.dev/docs/get-started/install" >&2
        exit 1
    fi
