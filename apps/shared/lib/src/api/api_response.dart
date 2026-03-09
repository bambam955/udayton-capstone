class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
  });

  final int statusCode;
  final T data;
  final Map<String, String> headers;
}
