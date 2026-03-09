import 'api_environment.dart';

class ApiConfig {
  const ApiConfig({
    required this.baseUri,
    required this.environment,
    this.timeout = const Duration(seconds: 20),
    this.defaultHeaders = const {},
  });

  final Uri baseUri;
  final ApiEnvironment environment;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  ApiConfig copyWith({
    Uri? baseUri,
    ApiEnvironment? environment,
    Duration? timeout,
    Map<String, String>? defaultHeaders,
  }) {
    return ApiConfig(
      baseUri: baseUri ?? this.baseUri,
      environment: environment ?? this.environment,
      timeout: timeout ?? this.timeout,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
    );
  }
}
