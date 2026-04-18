# Contributing to BizRush

## Prerequisites

### Dev Tooling

- [Docker](https://docs.docker.com/get-docker/) (for backend/mocks)
- [Flutter](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/)
- [just](https://github.com/casey/just) command runner
- [Android Studio + Android SDK/emulator](https://developer.android.com/studio) for Android targets.
  - [Flutter Android setup docs](https://docs.flutter.dev/get-started/install)
- [`pre-commit`](https://pre-commit.com/) (optional)

Docker is used for backend services (mocks) and the admin dashboard. Frontend apps run locally through installed Flutter toolchains.
Local Android runs additionally require Android Studio and the Android SDK/emulator setup on your host.

## Getting Started

```bash
# Clone the repository
git clone https://github.com/bizrush-capstone/bizrush.git
cd bizrush

# Install dependencies and verify local toolchain
just setup

# Start web dev server (http://localhost:8080)
just run main-web
```

If `pre-commit` is installed, `just setup` will automatically run `pre-commit install` to set up the Git hooks.

## Common Commands

| Command | Description |
|---------|-------------|
| `just run <services>` | Start backend services, run local Flutter apps, or run `admin` containerized |
| `just down` | Stop backend services |
| `just test <components>` | Run tests |
| `just check <components>` | Static source code analysis and linting |
| `just format <components>` | Format code |
| `just deps <components>` | Install dependencies (`flutter pub get`, `npm ci`, etc.) |
| `just build <component> [args]` | Build a deployable version of the specified component |
| `just doctor` | Run `flutter doctor -v` |
| `just clean <components>` | Clean build artifacts |
| `just` | List all available commands |

`main`, `driver`, and `shared` are Flutter components. `admin` and `mocks` use Node tooling.

## Running on Android

The emulator and connected devices run on the host.

### Linux / macOS

```bash
just --justfile apps/justfile emulator

just run main-android
just run driver-android
```

### Windows

1. Install [Android Studio](https://developer.android.com/studio) and create an emulator via Device Manager
2. Start the emulator
3. Run the app:
   ```bash
   just run main-android
   ```

## Testing

```bash
just test
```

## Code Quality

- Run `just check` before submitting changes
- Run `just format` to auto-format code
- SQL migrations/seeds are linted with SQLFluff (run `just --justfile db/justfile check` and auto-fix with `just --justfile db/justfile format`)
- Follow [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)

## Submitting Changes

1. Create a feature branch
2. Make your changes
3. Run `just check` and `just test` to verify
4. Write clear commit messages
5. Submit a pull request with a description of changes
