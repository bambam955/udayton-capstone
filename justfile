# BizRush — project orchestration
# Backend services always start; frontend services are opt-in.
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
        echo "Ensuring ADB server accepts remote connections..."
        adb kill-server 2>/dev/null || true
        adb -a -P 5037 start-server || echo "⚠ adb start-server failed — is adb installed?"
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
            {{ DC }} run --rm admin just build {{args}}
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
