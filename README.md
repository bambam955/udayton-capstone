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
    just up main-web
    ```

4. Run the admin dashboard:

    ```bash
    just up admin
    ```

5. Run a Flutter app in Android:

    ```bash
    just up main-android
    ```

> Flutter apps run locally; admin is run via Docker (`admin` Compose profile) for local development.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).
