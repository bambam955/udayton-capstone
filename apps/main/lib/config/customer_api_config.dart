import 'package:bizrush_shared/api.dart';

// The shared resolver owns the BIZRUSH_API_BASE_URL contract and local
// emulator fallback so both mobile apps target the API consistently.
ApiConfig buildCustomerApiConfig() {
  return ApiConfig(
    baseUri: Uri.parse(resolveApiBaseUrl()),
    environment: ApiEnvironment.development,
    defaultHeaders: const <String, String>{
      'x-client': 'bizrush-main',
    },
  );
}
