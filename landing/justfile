# List available recipes
default:
    @just --list

# Build the site locally
build:
    npm -C docs run build

# Run dev server
dev:
    npm -C docs run dev

# Reload site dependencies
deps:
    npm -C docs install --no-fund

# Set up the local dev environment
setup:
    npm -C docs install --no-fund --no-save
