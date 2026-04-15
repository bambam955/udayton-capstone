import 'package:bizrush_shared/api.dart';

// Mobile dev environments vary, so the base URL stays overrideable via
// --dart-define while still working out of the box for local web runs.
ApiConfig buildCustomerApiConfig() {
  // Android emulators need `10.0.2.2` to reach services on the host machine.
  // Other local targets can keep using `localhost`, and a dart-define still
  // overrides both defaults when a custom backend is needed.
  const configuredBaseUrl = String.fromEnvironment(
    'BIZRUSH_API_BASE_URL',
  );
  final baseUrl = resolveLocalApiBaseUrl(configuredBaseUrl: configuredBaseUrl);

  return ApiConfig(
    baseUri: Uri.parse(baseUrl),
    environment: ApiEnvironment.development,
    defaultHeaders: const <String, String>{
      'x-client': 'bizrush-main',
    },
  );
}
