import 'package:bizrush_shared/api.dart';

import 'driver_api_config.dart';

/// Bundles the concrete API clients the driver app needs at runtime.
class DriverAppDependencies {
  DriverAppDependencies({
    required this.authApi,
    required this.driverApi,
    required this.resourceApi,
  });

  factory DriverAppDependencies.production() {
    // All driver-facing clients share one transport and one session store so
    // auth state, headers, and error handling stay consistent across screens.
    final sessionStore = SecureSessionStore();
    final apiClient = HttpApiClient(
      config: buildDriverApiConfig(),
      sessionStore: sessionStore,
    );

    return DriverAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      driverApi: DriverMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );
  }

  final AuthApi authApi;
  final DriverMobileApi driverApi;
  final ResourceApi resourceApi;
}
