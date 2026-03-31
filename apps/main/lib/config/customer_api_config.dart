import 'package:bizrush_shared/api.dart';

// Mobile dev environments vary, so the base URL stays overrideable via
// --dart-define while still working out of the box for local web runs.
ApiConfig buildCustomerApiConfig() {
  // Keeping the base URL in a compile-time define makes simulator/device/web
  // switching possible without editing source.
  const baseUrl = String.fromEnvironment(
    'BIZRUSH_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  return ApiConfig(
    baseUri: Uri.parse(baseUrl),
    environment: ApiEnvironment.development,
    defaultHeaders: const <String, String>{
      'x-client': 'bizrush-main',
    },
  );
}
