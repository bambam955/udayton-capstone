import 'api_client.dart';
import 'api_json.dart';
import 'api_request.dart';

typedef ResourceDecoder<T> = T Function(Object? rawBody);

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
