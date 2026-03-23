class ApiRequest {
  const ApiRequest({
    required this.method,
    required this.path,
    this.queryParameters = const {},
    this.headers = const {},
    this.body,
  });

  final String method;
  final String path;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final Object? body;
}
