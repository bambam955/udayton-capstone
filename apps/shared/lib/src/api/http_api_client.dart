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

/// Default HTTP transport used by the shared API client.
///
/// The class centralizes request construction, auth header injection, timeout
/// handling, JSON decoding, and API error translation so the higher-level
/// mobile/resource clients can stay declarative.
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
    // Merge headers in increasing specificity so callers can still override
    // defaults when a single request needs custom behavior.
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
      // Every current write endpoint expects JSON, so request bodies are encoded
      // once here instead of leaving serialization to each API wrapper.
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
    // Treat empty bodies as `null` so `204`-style responses and mutation
    // endpoints without a payload can share the same decoding path.
    final body =
        response.body.trim().isEmpty ? null : _decodeJson(response.body);

    if (response.statusCode >= 400) {
      throw _errorFromResponse(response.statusCode, body);
    }

    try {
      // Some callers expect the raw decoded JSON while others provide a model
      // factory. Supporting both keeps the transport layer generic.
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

    // The API currently exposes most non-401 failures as general request
    // errors, so keep the classification conservative until richer kinds are
    // needed by the UI.
    return ApiError(
      kind: ApiErrorKind.server,
      statusCode: statusCode,
      message: message,
    );
  }
}
