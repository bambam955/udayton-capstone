import 'api_request.dart';
import 'api_response.dart';

typedef ApiDecoder<T> = T Function(Object? rawBody);

abstract interface class ApiClient {
  Future<ApiResponse<T>> send<T>(ApiRequest request, {ApiDecoder<T>? decoder});
}
