import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_config.dart';
import 'api_error.dart';
import 'api_json.dart';
import 'api_request.dart';
import 'api_response.dart';
import 'session_store.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({
    required ApiConfig config,
    http.Client? httpClient,
    SessionStore? sessionStore,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client(),
        _sessionStore = sessionStore;

  final ApiConfig _config;
  final http.Client _httpClient;
  final SessionStore? _sessionStore;

  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    ApiDecoder<T>? decoder,
  }) async {
    final session = await _sessionStore?.read();
    final uri = _buildUri(request);
    final headers = <String, String>{
      ..._config.defaultHeaders,
      ...request.headers,
      if (request.body != null) 'content-type': 'application/json',
      if (session != null && !session.isExpired)
        'authorization': 'Bearer ${session.accessToken}',
    };

    final httpRequest = http.Request(request.method, uri);
    httpRequest.headers.addAll(headers);
    if (request.body != null) {
      httpRequest.body = jsonEncode(request.body);
    }

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse =
          await _httpClient.send(httpRequest).timeout(_config.timeout);
    } on TimeoutException catch (error) {
      throw ApiError(
          kind: ApiErrorKind.timeout,
          message: 'Request timed out.',
          cause: error);
    } on http.ClientException catch (error) {
      throw ApiError(
          kind: ApiErrorKind.network, message: error.message, cause: error);
    } catch (error) {
      throw ApiError(
          kind: ApiErrorKind.unknown,
          message: 'Unexpected network failure.',
          cause: error);
    }

    final response = await http.Response.fromStream(streamedResponse);
    final body =
        response.body.trim().isEmpty ? null : _decodeJson(response.body);

    if (response.statusCode >= 400) {
      throw _errorFromResponse(response.statusCode, body);
    }

    try {
      final data = decoder == null ? body as T : decoder(body);
      return ApiResponse<T>(
        statusCode: response.statusCode,
        data: data,
        headers: response.headers,
      );
    } catch (error) {
      throw ApiError(
        kind: ApiErrorKind.decode,
        message: 'Failed to decode API response.',
        statusCode: response.statusCode,
        cause: error,
      );
    }
  }

  Uri _buildUri(ApiRequest request) {
    final base = _config.baseUri.resolve(request.path);
    return base.replace(
      queryParameters:
          request.queryParameters.isEmpty ? null : request.queryParameters,
    );
  }

  Object? _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (error) {
      throw ApiError(
        kind: ApiErrorKind.decode,
        message: 'Response was not valid JSON.',
        cause: error,
      );
    }
  }

  ApiError _errorFromResponse(int statusCode, Object? body) {
    String message = 'Request failed.';
    if (body is Map || body is Map<Object?, Object?>) {
      final json = asJsonMap(body);
      message = readString(json, 'message', fallback: message);
    }

    if (statusCode == 401) {
      return ApiError(
        kind: ApiErrorKind.unauthorized,
        statusCode: statusCode,
        message: message,
      );
    }

    if (statusCode >= 500) {
      return ApiError(
        kind: ApiErrorKind.server,
        statusCode: statusCode,
        message: message,
      );
    }

    return ApiError(
      kind: ApiErrorKind.server,
      statusCode: statusCode,
      message: message,
    );
  }
}
