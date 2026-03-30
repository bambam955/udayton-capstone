import 'dart:convert';

import 'package:bizrush_shared/api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('HttpApiClient', () {
    test('sends JSON requests with query params and bearer auth', () async {
      final sessionStore = InMemorySessionStore();
      await sessionStore.write(
        ApiSession(
          accessToken: 'access-token',
          expiresAt: DateTime.utc(2099, 1, 1),
          user: const AuthUser(
            id: 'cust-1',
            role: ApiUserRole.customer,
            email: 'customer@example.com',
          ),
        ),
      );

      final client = HttpApiClient(
        config: ApiConfig(
          baseUri: Uri.parse('https://api.example.com'),
          environment: ApiEnvironment.development,
          timeout: const Duration(seconds: 1),
          defaultHeaders: const {'x-client': 'main-app'},
        ),
        sessionStore: sessionStore,
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString(),
            'https://api.example.com/v1/test?category=produce&query=apples',
          );
          expect(request.headers['authorization'], 'Bearer access-token');
          expect(request.headers['content-type'], 'application/json');
          expect(request.headers['x-client'], 'main-app');
          expect(request.headers['x-screen'], 'catalog');
          expect(
            jsonDecode(request.body),
            <String, Object?>{'quantity': 2, 'notes': 'Leave at door'},
          );

          return http.Response(
            jsonEncode(<String, Object?>{'status': 'ok'}),
            200,
            headers: const {'x-trace-id': 'trace-123'},
          );
        }),
      );

      final response = await client.send<String>(
        const ApiRequest(
          method: 'POST',
          path: '/v1/test',
          queryParameters: <String, String>{
            'category': 'produce',
            'query': 'apples',
          },
          headers: <String, String>{'x-screen': 'catalog'},
          body: <String, Object?>{'quantity': 2, 'notes': 'Leave at door'},
        ),
        decoder: (rawBody) =>
            (rawBody as Map<Object?, Object?>)['status']! as String,
      );

      expect(response.statusCode, 200);
      expect(response.headers['x-trace-id'], 'trace-123');
      expect(response.data, 'ok');
    });

    test('does not attach an expired bearer token', () async {
      final sessionStore = InMemorySessionStore();
      await sessionStore.write(
        ApiSession(
          accessToken: 'expired-token',
          expiresAt: DateTime.utc(2000, 1, 1),
          user: const AuthUser(
            id: 'cust-1',
            role: ApiUserRole.customer,
            email: 'customer@example.com',
          ),
        ),
      );

      final client = HttpApiClient(
        config: ApiConfig(
          baseUri: Uri.parse('https://api.example.com'),
          environment: ApiEnvironment.development,
          timeout: const Duration(seconds: 1),
        ),
        sessionStore: sessionStore,
        httpClient: MockClient((request) async {
          expect(request.headers.containsKey('authorization'), isFalse);
          return http.Response(
              jsonEncode(<String, Object?>{'status': 'ok'}), 200);
        }),
      );

      final response = await client.send<String>(
        const ApiRequest(method: 'GET', path: '/v1/test'),
        decoder: (rawBody) =>
            (rawBody as Map<Object?, Object?>)['status']! as String,
      );

      expect(response.data, 'ok');
    });

    test('maps 401 responses into unauthorized ApiError values', () async {
      final client = HttpApiClient(
        config: ApiConfig(
          baseUri: Uri.parse('https://api.example.com'),
          environment: ApiEnvironment.development,
          timeout: const Duration(seconds: 1),
        ),
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode(<String, Object?>{'message': 'Missing token'}),
            401,
          );
        }),
      );

      await expectLater(
        () => client.send<void>(
          const ApiRequest(method: 'GET', path: '/v1/protected'),
          decoder: (_) {},
        ),
        throwsA(
          isA<ApiError>()
              .having((error) => error.kind, 'kind', ApiErrorKind.unauthorized)
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'Missing token'),
        ),
      );
    });

    test('maps transport delays into timeout ApiError values', () async {
      final client = HttpApiClient(
        config: ApiConfig(
          baseUri: Uri.parse('https://api.example.com'),
          environment: ApiEnvironment.development,
          timeout: const Duration(milliseconds: 10),
        ),
        httpClient: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        () => client
            .send<void>(const ApiRequest(method: 'GET', path: '/v1/slow')),
        throwsA(
          isA<ApiError>()
              .having((error) => error.kind, 'kind', ApiErrorKind.timeout),
        ),
      );
    });

    test('maps malformed JSON responses into decode ApiError values', () async {
      final client = HttpApiClient(
        config: ApiConfig(
          baseUri: Uri.parse('https://api.example.com'),
          environment: ApiEnvironment.development,
          timeout: const Duration(seconds: 1),
        ),
        httpClient: MockClient((request) async {
          return http.Response('not-json', 200);
        }),
      );

      await expectLater(
        () => client
            .send<void>(const ApiRequest(method: 'GET', path: '/v1/bad-json')),
        throwsA(
          isA<ApiError>()
              .having((error) => error.kind, 'kind', ApiErrorKind.decode),
        ),
      );
    });
  });
}
