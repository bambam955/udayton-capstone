import 'package:bizrush_shared/api.dart';

// Driver builds use the same backend as the main customer app, with an
// override hook for device-specific local networking.
ApiConfig buildDriverApiConfig() {
  // Android emulators need `10.0.2.2` to reach host-local services, while
  // other local targets can continue using `localhost`. A dart-define still
  // wins when the app needs to talk to a physical device or remote backend.
  const configuredBaseUrl = String.fromEnvironment(
    'BIZRUSH_API_BASE_URL',
  );
  final baseUrl = resolveLocalApiBaseUrl(configuredBaseUrl: configuredBaseUrl);

  return ApiConfig(
    baseUri: Uri.parse(baseUrl),
    environment: ApiEnvironment.development,
    defaultHeaders: const <String, String>{
      'x-client': 'bizrush-driver',
    },
  );
}
