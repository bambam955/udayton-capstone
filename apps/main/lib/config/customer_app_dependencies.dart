import 'package:bizrush_shared/api.dart';

import 'customer_api_config.dart';

/// Bundles the concrete clients needed by the customer experience.
class CustomerAppDependencies {
  CustomerAppDependencies({
    required this.authApi,
    required this.customerApi,
    required this.resourceApi,
  });

  factory CustomerAppDependencies.production() {
    // The customer app shares one authenticated transport across auth,
    // mobile-specific endpoints, and the generic resource API.
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
