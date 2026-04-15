import 'dart:async';

import 'package:bizrush_shared/api.dart';

typedef ApiRequestHandler = FutureOr<Object?> Function(ApiRequest request);

// Lightweight fake client used by the package unit tests to verify
// request construction without depending on a network transport.
class RecordingApiClient implements ApiClient {
  RecordingApiClient(this._handler);

  final ApiRequestHandler _handler;
  final List<ApiRequest> requests = <ApiRequest>[];

  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    ApiDecoder<T>? decoder,
  }) async {
    requests.add(request);
    final raw = await _handler(request);
    final data = decoder == null ? raw as T : decoder(raw);
    return ApiResponse<T>(statusCode: 200, data: data);
  }
}
