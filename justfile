# List available recipes
default:
    @just --list

# ---------- Build commands ---------- #

# Build for web
build-web: deps
    cd app && flutter build web

# Build APK (debug or release)
build-apk target='debug': deps
    cd app && flutter build apk --{{target}}

# Build Android App Bundle for Play Store
build-aab: deps
    cd app && flutter build appbundle --release

# ---------- Run commands ---------- #

# Run on Chrome (web)
run-web: deps
    cd app && flutter run -d chrome

# Run on Android emulator (launches emulator if needed)
run-android: deps _ensure-emulator
    cd app && flutter run -d emulator-5554

# Run on a connected physical device
run-device: deps
    cd app && flutter run -d $(flutter devices | grep -v Chrome | grep -v emulator | head -1 | awk '{print $1}')

# Run with custom device/args
run *args: deps
    cd app && flutter run {{args}}

# ---------- Development commands ---------- #

# Run all unit tests
test: deps
    cd app && flutter test

# Run tests with coverage
test-cov: deps
    cd app && flutter test --coverage

# Check for issues (analyze)
check: deps
    cd app && flutter analyze

# Format code
format:
    cd app && dart format .

# Install dependencies
deps:
    cd app && flutter pub get

# Clean build artifacts
clean:
    cd app && flutter clean

# Full rebuild (clean + deps + build)
rebuild: clean deps build-apk

# ---------- Utilities ---------- #

# Launch the Android emulator
launch-emulator:
    flutter emulators --launch Medium_Phone_API_36.1

# Internal: ensure emulator is running
_ensure-emulator:
    @flutter devices | grep -q emulator || just launch-emulator && sleep 5
