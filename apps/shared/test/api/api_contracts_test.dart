import 'package:bizrush_shared/api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiConfig copyWith updates selected values', () {
    final base = ApiConfig(
      baseUri: Uri.parse('https://api.example.com'),
      environment: ApiEnvironment.development,
      defaultHeaders: const {'x-client': 'customer'},
    );

    final next = base.copyWith(
      timeout: const Duration(seconds: 5),
      defaultHeaders: const {'x-client': 'driver'},
    );

    expect(next.baseUri, Uri.parse('https://api.example.com'));
    expect(next.environment, ApiEnvironment.development);
    expect(next.timeout, const Duration(seconds: 5));
    expect(next.defaultHeaders['x-client'], 'driver');
  });

  test('ApiRequest and ApiResponse hold typed payloads', () {
    const request = ApiRequest(
      method: 'GET',
      path: '/orders',
      queryParameters: {'status': 'active'},
    );
    const response = ApiResponse<List<String>>(
      statusCode: 200,
      data: ['ord_1001'],
      headers: {'content-type': 'application/json'},
    );

    expect(request.method, 'GET');
    expect(request.path, '/orders');
    expect(request.queryParameters['status'], 'active');
    expect(response.statusCode, 200);
    expect(response.data.single, 'ord_1001');
  });

  test('ApiError formats context in toString', () {
    const err = ApiError(
      kind: ApiErrorKind.unauthorized,
      statusCode: 401,
      message: 'Missing token',
    );

    expect(err.toString(), contains('unauthorized'));
    expect(err.toString(), contains('401'));
    expect(err.toString(), contains('Missing token'));
  });
}
