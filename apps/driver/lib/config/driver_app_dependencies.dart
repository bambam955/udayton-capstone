import 'package:bizrush_shared/api.dart';

import 'driver_api_config.dart';

class DriverAppDependencies {
  DriverAppDependencies({
    required this.authApi,
    required this.driverApi,
    required this.resourceApi,
  });

  factory DriverAppDependencies.production() {
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
