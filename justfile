# BizRush — project orchestration
# Backend services always start; frontend services are opt-in.
# Usage: just up <service>...   where service is main-web, driver-web,
#        main-android, driver-android, or admin

set shell := ["bash", "-cu"]

DC := "docker compose"
ALL_COMPONENTS := "main driver"

# ---------- Main commands ---------- #

# List available recipes
default:
    @echo "Available recipes:"
    @JUST_LIST_HEADING="" just --list
    @echo ""
    @echo "Components: {{ALL_COMPONENTS}}"

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
    needs_adb=false
    for svc in {{services}}; do
        flags+=" --profile $svc"
        [[ "$svc" == *-android ]] && needs_adb=true
    done
    if $needs_adb; then
        echo "Enabling ADB over TCP..."
        adb tcpip 5555 || echo "⚠ adb tcpip failed — is an emulator running?"
    fi
    {{ DC }} $flags up

# Stop all services
down:
    {{ DC }} down

# ---------- Dev commands (default to all components) ---------- #

# Run tests
test *components:
    just _foreach test {{components}}

# Analyze code
check *components:
    just _foreach check {{components}}

# Format code
format *components:
    just _foreach format {{components}}

# Install dependencies
deps *components:
    just _foreach deps {{components}}

# Clean build artifacts
clean *components:
    just _foreach clean {{components}}

# Run flutter doctor
doctor:
    {{ DC }} run --rm dev-tools just doctor

# ---------- Build commands ---------- #

# Build a component (pass extra args after name, e.g. just build main --release)
build component *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{component}}" in
        main|driver)
            {{ DC }} run --rm android just build "{{component}}" {{args}}
            ;;
        # admin)
        #     {{ DC }} run --rm admin-dev just build {{args}}
        #     ;;
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
    {{ DC }} run --rm dev-tools bash

# Verify and set up the development environment
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v pre-commit >/dev/null && pre-commit install || echo "⚠ pre-commit not installed (optional)"
    command -v docker >/dev/null || { echo "❌ Docker not installed"; exit 1; }
    COMPOSE_PROFILES=tools,main-web,driver-web,main-android,driver-android \
        {{ DC }} build
    just deps

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

# ---------- Internal ---------- #

# Loop over components (or all if none given) and run a recipe for each
[private]
_foreach recipe *components:
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
            {{ DC }} run --rm dev-tools just "{{recipe}}" "{{component}}"
            ;;
        # admin)
        #     {{ DC }} run --rm admin-dev just "{{recipe}}"
        #     ;;
        # api)
        #     {{ DC }} run --rm api-dev just "{{recipe}}"
        #     ;;
        *)
            echo "❌ Unknown component: {{component}}"
            echo "Known components: {{ALL_COMPONENTS}}"
            exit 1
            ;;
    esac
