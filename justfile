# BizRush — project orchestration
# Backend services run in Docker; Flutter apps run locally; admin runs in Docker.
# Usage: just up <service>... where service is main-web, driver-web,
#        main-android, driver-android, or admin

set shell := ["bash", "-cu"]

ROOT_DC := "docker compose --project-name bizrush -f docker-compose.yml"
ALL_COMPONENTS := "main driver admin mocks"
ALL_UP_SERVICE_HELP := "main-web (or main), driver-web (or driver), main-android, driver-android, admin"

# ---------- Main commands ---------- #

# List available recipes
default:
    @echo "Components: {{ALL_COMPONENTS}}"
    @echo "Run services: {{ALL_UP_SERVICE_HELP}}"
    @echo ""
    @just --list --unsorted
    @echo ""
    @echo "Apps recipes:"
    @just --justfile apps/justfile --list-heading "" --list-prefix "    apps/" --list --unsorted
    @echo ""
    @echo "For admin/db/mocks recipes:"
    @echo "    just --justfile <component>/justfile"

# Start backend services in Docker, then run selected app(s) locally
up *services:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{services}}" ]; then
        echo "Usage: just up <service>..."
        echo "Services: {{ ALL_UP_SERVICE_HELP }}"
        exit 2
    fi

    launch_local() {
        case "$1" in
            main|main-web)
                local port="${MAIN_WEB_PORT:-8080}"
                echo "Starting main web app on http://localhost:${port}"
                (cd apps/main && flutter run -d web-server --web-hostname localhost --web-port "${port}")
                ;;
            driver|driver-web)
                local port="${DRIVER_WEB_PORT:-8081}"
                echo "Starting driver web app on http://localhost:${port}"
                (cd apps/driver && flutter run -d web-server --web-hostname localhost --web-port "${port}")
                ;;
            main-android)
                echo "Starting main Android app"
                (cd apps/main && flutter run)
                ;;
            driver-android)
                echo "Starting driver Android app"
                (cd apps/driver && flutter run)
                ;;
            *)
                echo "❌ Unknown service: $1"
                echo "Known services: {{ ALL_UP_SERVICE_HELP }}"
                exit 1
                ;;
        esac
    }

    requested="{{services}}"
    read -r -a services <<< "$requested"
    local_services=()
    has_admin=false
    for svc in "${services[@]}"; do
        case "$svc" in
            main|main-web|driver|driver-web|main-android|driver-android)
                local_services+=("$svc")
                ;;
            admin)
                has_admin=true
                ;;
            *)
                echo "❌ Unknown service: $svc"
                echo "Known services: {{ ALL_UP_SERVICE_HELP }}"
                exit 1
                ;;
        esac
    done

    echo "Starting backend services with docker compose..."
    {{ ROOT_DC }} up -d

    if $has_admin; then
        if [ "${#local_services[@]}" -eq 0 ]; then
            echo "Starting admin dashboard in Docker"
            {{ ROOT_DC }} --profile admin up admin
            exit 0
        fi

        {{ ROOT_DC }} --profile admin up -d admin
    fi

    if [ "${#local_services[@]}" -eq 0 ]; then
        echo "No local services selected."
        exit 0
    fi

    pids=()
    if [ "${#local_services[@]}" -eq 1 ]; then
        launch_local "${local_services[0]}"
        exit 0
    fi

    for svc in "${local_services[@]}"; do
        launch_local "$svc" &
        pids+=("$!")
    done

    echo "Started ${#local_services[@]} local service(s) in the background: ${pids[*]}"
    wait

# Stop backend services
down:
    {{ ROOT_DC }} --profile admin down --remove-orphans

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
    just apps/doctor

# ---------- Build commands ---------- #

# Build a component (pass extra args after name, e.g. just build main --release)
build component *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{component}}" in
        main|driver)
            just apps/build "{{component}}" {{args}}
            ;;
        admin)
            docker buildx build --tag bizrush/admin:latest --target prod -f admin-base/Dockerfile admin-base/
            ;;
        mocks)
            echo "Nothing to build"
            ;;
        *)
            echo "❌ Unknown component: {{component}}"
            echo "Known components: {{ALL_COMPONENTS}}"
            exit 1
            ;;
    esac

# ---------- Dev environment ---------- #

# Open a local shell
shell:
    bash

# Verify and set up the development environment
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v pre-commit >/dev/null && pre-commit install || echo "⚠ pre-commit not installed (optional)"
    command -v docker >/dev/null || { echo "❌ Docker not installed"; exit 1; }
    command -v flutter >/dev/null || { echo "❌ Flutter not installed"; exit 1; }
    command -v npm >/dev/null || { echo "❌ npm not installed"; exit 1; }
    COMPOSE_PROJECT_NAME=bizrush {{ ROOT_DC }} build admin
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

# Map a component to local tooling and run the recipe
[private]
_run-for recipe component:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{component}}" in
        main|driver)
            just --justfile apps/justfile "{{recipe}}" "{{component}}"
            ;;
        admin)
            just --justfile admin-base/justfile "{{recipe}}"
            ;;
        mocks)
            just --justfile mocks/justfile "{{recipe}}"
            ;;
        *)
            echo "❌ Unknown component: {{component}}"
            echo "Known components: {{ALL_COMPONENTS}}"
            exit 1
            ;;
    esac

# ---------- Android commands ---------- #

# Start emulator on host
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
