# Contributing to BizRush

## Prerequisites

### Flutter & Android SDK Setup

1. **Install Flutter**
   - Follow the [Flutter installation guide](https://docs.flutter.dev/install/manual) for your OS
   - Verify installation: `flutter doctor`

2. **Set up Android SDK**
   - Install [Android Studio](https://developer.android.com/studio)
   - Open SDK Manager (Tools > SDK Manager) and install:
     - SDK Platform (latest API level)
     - Android SDK Build Tools
     - Android SDK Platform Tools
   - Accept licenses: `flutter doctor --android-licenses`

3. **Verify setup**
   ```bash
   flutter doctor
   ```
   All items should be checked. Fix any warnings before developing.

## Development Workflow

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect an Android device or start an emulator
4. Run `flutter run` to build and launch the app

## Testing

Run tests with:

```bash
flutter test
```

## Code Quality

Follow [Flutter style guidelines](https://dart.dev/guides/language/effective-dart/style).

## Submitting Changes

- Create a feature branch
- Write clear commit messages
- Submit a pull request with a description of changes
