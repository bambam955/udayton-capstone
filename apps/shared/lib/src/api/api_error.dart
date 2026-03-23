enum ApiErrorKind { network, timeout, unauthorized, server, decode, unknown }

class ApiError implements Exception {
  const ApiError({
    required this.kind,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    return 'ApiError(kind: $kind, statusCode: $statusCode, message: $message)';
  }
}
