import 'api_client.dart';
import 'api_json.dart';
import 'api_request.dart';

typedef ResourceDecoder<T> = T Function(Object? rawBody);

/// Small helper for talking to the generic `/v1/*` resource endpoints.
///
/// The mobile-specific APIs cover opinionated workflows, while this class is
/// used for CRUD-style tables such as cart items, addresses, payouts, and
/// support tickets that still follow the shared resource envelope.
class ResourceApi {
  const ResourceApi(this._client);

  final ApiClient _client;

  Future<List<T>> list<T>(
    String path,
    ResourceDecoder<T> decoder, {
    Map<String, String> queryParameters = const {},
  }) async {
    final response = await _client.send<List<T>>(
      ApiRequest(
        method: 'GET',
        path: path,
        queryParameters: queryParameters,
      ),
      decoder: (rawBody) {
        // Resource endpoints always wrap records under a `data` array, so this
        // adapter flattens the envelope before model code sees it.
        final body = asJsonMap(rawBody);
        return [
          for (final item in asJsonList(body['data'])) decoder(item),
        ];
      },
    );
    return response.data;
  }

  Future<T> get<T>(String path, ResourceDecoder<T> decoder) async {
    final response = await _client.send<T>(
      ApiRequest(method: 'GET', path: path),
      decoder: (rawBody) {
        // Single-resource reads still use the same `data` wrapper, just with a
        // single object payload instead of a list.
        final body = asJsonMap(rawBody);
        return decoder(body['data']);
      },
    );
    return response.data;
  }

  Future<T> create<T>(
      String path, Object body, ResourceDecoder<T> decoder) async {
    final response = await _client.send<T>(
      ApiRequest(method: 'POST', path: path, body: body),
      decoder: (rawBody) {
        final json = asJsonMap(rawBody);
        return decoder(json['data']);
      },
    );
    return response.data;
  }

  Future<T> update<T>(
      String path, Object body, ResourceDecoder<T> decoder) async {
    final response = await _client.send<T>(
      ApiRequest(method: 'PATCH', path: path, body: body),
      decoder: (rawBody) {
        final json = asJsonMap(rawBody);
        return decoder(json['data']);
      },
    );
    return response.data;
  }

  Future<void> delete(String path) async {
    await _client.send<void>(
      ApiRequest(method: 'DELETE', path: path),
      decoder: (_) {},
    );
  }
}
