# BizRush

A platform for small businesses to rush-deliver supplies quickly and accurately.

The Flutter customer app (`apps/main`) and driver app (`apps/driver`) share common foundations through `apps/shared` (`bizrush_shared`).

## Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install), [Docker](https://docs.docker.com/get-docker/), and [`just`](https://github.com/casey/just).
2. One-time setup:

    ```bash
    just setup
    ```

3. Run the main BizRush web app:

    ```bash
    just run main-web
    ```

4. Run the backend API + database:

    ```bash
    just run
    ```

5. Run the admin dashboard:

    ```bash
    just run admin
    ```

6. Run a Flutter app in Android:

    ```bash
    just run main-android
    ```

    Android emulator builds use `http://10.0.2.2:3000` by default so the app can reach the API published on the host machine by Docker.

7. Build a mobile APK against the seeded beta API:

    ```bash
    just build-beta main
    just build-beta driver
    ```

    Manual production/demo builds can pass the same API target explicitly with `--dart-define=BIZRUSH_API_BASE_URL=https://bizrush-beta-api.onrender.com`.

> Flutter apps run locally; admin is run via Docker (`admin` Compose profile) for local development.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).
