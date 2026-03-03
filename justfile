# BizRush — project orchestration
# Backend services always start (WIP); frontend services are opt-in.
# Usage: just up <service>...   where service is main-web, driver-web,
#        main-android, driver-android, or admin

set shell := ["bash", "-cu"]

DC := "docker compose"
ALL_COMPONENTS := "main driver admin"
ALL_DC_SERVICES := "main-web driver-web main-android driver-android admin"

# ---------- Main commands ---------- #

# List available recipes
default:
    @echo "Components: {{ALL_COMPONENTS}}"
    @echo "Docker Compose services: {{ ALL_DC_SERVICES }}"
    @echo ""
    @just --list --unsorted
    @echo ""
    @echo "Apps recipes:"
    @just --justfile apps/justfile --list-heading "" --list-prefix "    apps/" --list --unsorted
    @echo ""
    @echo "Admin recipes:"
    @just --justfile admin-base/justfile --list-heading "" --list-prefix "    admin/" --list --unsorted

# Start backend + selected frontend services
up *services:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{services}}" ]; then
        echo "Usage: just up <service>..."
        echo "Services: {{ ALL_DC_SERVICES }}"
        exit 2
    fi
    echo "Running services {{ services }}..."
    flags=""
    needs_adb=false
    for svc in {{services}}; do
        flags+=" --profile $svc"
        [[ "$svc" == *-android ]] && needs_adb=true
    done
    if $needs_adb; then
        just android-preflight
    fi
    {{ DC }} $flags up -d
    # Attach to the first service for interactive stdin (hot reload keys)
    attach_svc="$(echo {{services}} | awk '{print $1}')"
    echo "Attaching to service $attach_svc..."
    {{ DC }} attach "$attach_svc"

# Stop all services
down:
    COMPOSE_PROFILES=main-web,driver-web,main-android,driver-android,admin {{ DC }} down

# ---------- Dev commands (default to all components) ---------- #

# Run tests
test *components:
    just _foreach-component test {{components}}

# Analyze code
check *components:
    just _foreach-component check {{components}}

# Format code
format *components:
    just _foreach-component format {{components}}

# Install dependencies
deps *components:
    just _foreach-component deps {{components}}

# Clean build artifacts
clean *components:
    just _foreach-component clean {{components}}

# Run flutter doctor
doctor:
    {{ DC }} run --rm apps-android just doctor

# ---------- Build commands ---------- #

# Build a component (pass extra args after name, e.g. just build main --release)
build component *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{component}}" in
        main|driver)
            {{ DC }} run --rm apps-android just build "{{component}}" {{args}}
            ;;
        admin)
            # Build the docker image
            docker buildx build --tag bizrush/admin:latest --target prod -f admin-base/Dockerfile admin-base/
            ;;
        # api)
        #     {{ DC }} run --rm api-dev just build {{args}}
        #     ;;
        *)
            echo "❌ Unknown component: {{component}}"
            echo "Known components: {{ALL_COMPONENTS}}"
            exit 1
            ;;
    esac

# ---------- Dev environment ---------- #

# Open a shell in the dev container
shell:
    {{ DC }} run --rm apps-dev-tools bash

# Verify and set up the development environment
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v pre-commit >/dev/null && pre-commit install || echo "⚠ pre-commit not installed (optional)"
    command -v docker >/dev/null || { echo "❌ Docker not installed"; exit 1; }
    COMPOSE_PROFILES=tools,main-web,driver-web,main-android,driver-android,admin \
        {{ DC }} build
    just deps

# ---------- Internal ---------- #

# Loop over components (or all if none given) and run a recipe for each
[private]
_foreach-component recipe *components:
    #!/usr/bin/env bash
    set -euo pipefail
    targets="{{components}}"
    if [ -z "$targets" ]; then
        targets="{{ALL_COMPONENTS}}"
    fi
    for c in $targets; do
        just _run-for "{{recipe}}" "$c"
    done

# Map a component to its Docker service and run the recipe
[private]
_run-for recipe component:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{component}}" in
        main|driver)
            {{ DC }} run --rm apps-dev-tools just "{{recipe}}" "{{component}}"
            ;;
        admin)
            {{ DC }} run --rm admin-dev-tools just "{{recipe}}"
            ;;
        # api)
        #     {{ DC }} run --rm api-dev just "{{recipe}}"
        #     ;;
        *)
            echo "❌ Unknown component: {{component}}"
            echo "Known components: {{ALL_COMPONENTS}}"
            exit 1
            ;;
    esac

# ---------- Android commands ---------- #

# Start emulator on host (for connecting from Docker)
emulator:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -s)" in
        Linux|Darwin)
            command -v flutter >/dev/null || {
                echo "❌ Flutter not installed"; exit 1
            }
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

# Verify host ADB/emulator state for Android Docker workflows
android-preflight:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v adb >/dev/null 2>&1; then
        echo "ERROR: adb not found on host."
        echo "Install Android platform-tools and retry."
        exit 1
    fi
    echo "Starting host ADB server (listening for Docker clients)..."
    adb kill-server >/dev/null 2>&1 || true
    if ! adb -a start-server >/dev/null 2>&1; then
        echo "WARNING: 'adb -a start-server' failed; falling back to 'adb start-server'."
        adb start-server >/dev/null
    fi
    devices="$(adb devices | awk 'NR>1 && $2=="device" {print $1}')"
    if [ -z "$devices" ]; then
        echo "ERROR: no Android devices/emulators detected on host."
        echo "Start an emulator on host first (for example: just emulator), then retry."
        exit 1
    fi
    count="$(printf '%s\n' "$devices" | sed '/^$/d' | wc -l | tr -d ' ')"
    if [ "$count" -gt 1 ] && [ -z "${ANDROID_SERIAL:-}" ]; then
        echo "WARNING: multiple devices detected. Set ANDROID_SERIAL=<device-id> to target one explicitly."
    fi
    adb_host="${ADB_HOST:-host.docker.internal}"
    adb_port="${ADB_PORT:-5037}"
    echo "Verifying Docker can reach host ADB at ${adb_host}:${adb_port}..."
    if ! {{ DC }} run --rm --no-deps \
        -e ADB_SERVER_SOCKET="tcp:${adb_host}:${adb_port}" \
        apps-android bash -lc 'adb devices >/dev/null'; then
        echo "ERROR: Docker cannot connect to host ADB at ${adb_host}:${adb_port}."
        echo "Try: adb kill-server && adb -a start-server"
        echo "Then re-run: just up main-android"
        exit 1
    fi
    echo "ADB preflight OK. Containers will use ADB_SERVER_SOCKET=tcp:${adb_host}:${adb_port}"
