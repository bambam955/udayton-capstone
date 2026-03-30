import 'package:bizrush_shared/api.dart';

import 'customer_api_config.dart';

class CustomerAppDependencies {
  CustomerAppDependencies({
    required this.authApi,
    required this.customerApi,
    required this.resourceApi,
  });

  factory CustomerAppDependencies.production() {
    final sessionStore = SecureSessionStore();
    final apiClient = HttpApiClient(
      config: buildCustomerApiConfig(),
      sessionStore: sessionStore,
    );

    return CustomerAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      customerApi: CustomerMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );
  }

  final AuthApi authApi;
  final CustomerMobileApi customerApi;
  final ResourceApi resourceApi;
}
