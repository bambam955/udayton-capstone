import 'package:bizrush_shared/api.dart';

// Driver builds use the same backend as the main customer app, with an
// override hook for device-specific local networking.
ApiConfig buildDriverApiConfig() {
  const baseUrl = String.fromEnvironment(
    'BIZRUSH_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  return ApiConfig(
    baseUri: Uri.parse(baseUrl),
    environment: ApiEnvironment.development,
    defaultHeaders: const <String, String>{
      'x-client': 'bizrush-driver',
    },
  );
}
