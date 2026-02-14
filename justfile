# BizRush — project orchestration
# Backend services always start; frontend services are opt-in.
# Usage: just up <service>...   where service is main-web, driver-web,
#        main-android, driver-android, or admin

set shell := ["bash", "-cu"]

DC := "docker compose"

# ---------- Main commands ---------- #

# List available recipes
default:
    @echo "Project recipes:"
    @JUST_LIST_HEADING="" just --list
    @echo ""
    @echo "App recipes (run via Docker):"
    @JUST_LIST_HEADING="" just --justfile apps/justfile --list

# Start backend + selected frontend services
up *services:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{services}}" ]; then
        echo "Usage: just up <service>..."
        echo "Services: main-web, driver-web, main-android, driver-android, admin"
        exit 2
    fi
    flags=""
    for svc in {{services}}; do
        flags+=" --profile $svc"
    done
    {{ DC }} $flags up

# Stop all services
down:
    {{ DC }} down

# ---------- App commands (delegated to apps/justfile inside container) ---------- #

# Run tests
test app: (_docker-dev "test" app)

# Analyze code
check app: (_docker-dev "check" app)

# Format code
format app: (_docker-dev "format" app)

# Install dependencies
deps app: (_docker-dev "deps" app)

# Clean build artifacts
clean app: (_docker-dev "clean" app)

# Run flutter doctor
doctor: (_docker-dev-raw "doctor")

# ---------- Build commands ---------- #

# Build APK (debug or release)
build app target='debug':
    {{ DC }} run --rm android just build {{ app }} {{ target }}

# ---------- Dev environment ---------- #

# Open a shell in the dev container
shell:
    {{ DC }} run --rm dev-tools bash

# Verify and set up the development environment
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v pre-commit >/dev/null && pre-commit install || echo "⚠ pre-commit not installed (optional)"
    command -v docker >/dev/null || { echo "❌ Docker not installed"; exit 1; }
    COMPOSE_PROFILES=tools,main-web,driver-web,main-android,driver-android \
        {{ DC }} build
    {{ DC }} run --rm dev-tools just deps main
    {{ DC }} run --rm dev-tools just deps driver

# ---------- Emulator helpers (run on host) ---------- #

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

# Enable ADB over TCP (run on host before using android profiles)
adb-tcp:
    adb tcpip 5555

# ---------- Internal ---------- #

# Run an apps/justfile recipe inside the dev-tools container
[private]
_docker-dev recipe app:
    {{ DC }} run --rm dev-tools just {{ recipe }} {{ app }}

# Run an apps/justfile recipe (no app arg) inside the dev-tools container
[private]
_docker-dev-raw recipe:
    {{ DC }} run --rm dev-tools just {{ recipe }}
