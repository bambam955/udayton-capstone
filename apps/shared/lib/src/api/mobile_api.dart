import 'api_client.dart';
import 'api_json.dart';
import 'api_models.dart';
import 'api_request.dart';
import 'session_store.dart';

/// Authentication API shared by the customer and driver apps.
class AuthApi {
  const AuthApi(this._client, this._sessionStore);

  final ApiClient _client;
  final SessionStore _sessionStore;

  Future<ApiSession?> restoreSession() {
    return _sessionStore.read();
  }

  Future<ApiSession> signup({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    String? deviceInfo,
  }) async {
    // Persist the resulting session immediately so app shells can resume from
    // secure storage on the next launch without re-running the signup flow.
    final response = await _client.send<AuthResult>(
      ApiRequest(
        method: 'POST',
        path: '/v1/auth/signup',
        body: {
          'email': email,
          'password': password,
          if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (deviceInfo != null && deviceInfo.isNotEmpty)
            'deviceInfo': deviceInfo,
        },
      ),
      decoder: AuthResult.fromJson,
    );
    final session = ApiSession.fromAuthResult(response.data);
    await _sessionStore.write(session);
    return session;
  }

  Future<ApiSession> login({
    required ApiUserRole role,
    required String email,
    required String password,
    String? deviceInfo,
  }) async {
    // Role is part of the login payload because the backend allows the same
    // auth surface to back multiple app experiences.
    final response = await _client.send<AuthResult>(
      ApiRequest(
        method: 'POST',
        path: '/v1/auth/login',
        body: {
          'role': apiUserRoleToWire(role),
          'email': email,
          'password': password,
          if (deviceInfo != null && deviceInfo.isNotEmpty)
            'deviceInfo': deviceInfo,
        },
      ),
      decoder: AuthResult.fromJson,
    );
    final session = ApiSession.fromAuthResult(response.data);
    await _sessionStore.write(session);
    return session;
  }

  Future<ApiPrincipal> me() async {
    // `me` validates that the restored bearer token still maps to a live
    // server-side session before the shell trusts the cached session object.
    final response = await _client.send<ApiPrincipal>(
      const ApiRequest(method: 'GET', path: '/v1/auth/me'),
      decoder: (rawBody) {
        final principal = asJsonMap(rawBody)['principal'];
        return ApiPrincipal.fromJson(principal);
      },
    );
    return response.data;
  }

  Future<void> logout(ApiUserRole role) async {
    try {
      await _client.send<void>(
        ApiRequest(
          method: 'POST',
          path: '/v1/auth/logout',
          body: {'role': apiUserRoleToWire(role)},
        ),
        decoder: (_) {},
      );
    } finally {
      // Always clear local state even if the network call fails so the app
      // never gets stuck on a stale, half-invalid session.
      await _sessionStore.clear();
    }
  }
}

/// Customer-specific convenience wrapper around the mobile backend routes.
class CustomerMobileApi {
  const CustomerMobileApi(this._client);

  final ApiClient _client;

  Future<CustomerBootstrap> bootstrap() async {
    // Bootstrap intentionally returns a wide, ready-to-render payload for the
    // shell's first load.
    final response = await _client.send<CustomerBootstrap>(
      const ApiRequest(method: 'GET', path: '/v1/mobile/customer/bootstrap'),
      decoder: CustomerBootstrap.fromJson,
    );
    return response.data;
  }

  Future<CustomerCatalog> catalog({
    required String retailerLocationId,
    String? category,
    String? query,
  }) async {
    // Optional filters are omitted entirely so the backend can apply its
    // default category/search behavior without empty-string special cases.
    final response = await _client.send<CustomerCatalog>(
      ApiRequest(
        method: 'GET',
        path: '/v1/mobile/customer/catalog',
        queryParameters: {
          'retailerLocationId': retailerLocationId,
          if (category != null && category.isNotEmpty) 'category': category,
          if (query != null && query.isNotEmpty) 'query': query,
        },
      ),
      decoder: CustomerCatalog.fromJson,
    );
    return response.data;
  }

  Future<CustomerRetailerConnection> connectRetailer(String retailerId) async {
    final response = await _client.send<CustomerRetailerConnection>(
      ApiRequest(
        method: 'POST',
        path: '/v1/mobile/customer/retailers/$retailerId/connect',
      ),
      decoder: CustomerRetailerConnection.fromJson,
    );
    return response.data;
  }

  Future<CustomerRetailerConnection> disconnectRetailer(
      String retailerId) async {
    final response = await _client.send<CustomerRetailerConnection>(
      ApiRequest(
        method: 'POST',
        path: '/v1/mobile/customer/retailers/$retailerId/disconnect',
      ),
      decoder: CustomerRetailerConnection.fromJson,
    );
    return response.data;
  }

  Future<CustomerCheckout> checkout({
    required String cartId,
    required String addressId,
    String? deliveryNotes,
    int? tipCents,
  }) async {
    // Checkout is a higher-level mobile action rather than a generic resource
    // write because it creates multiple records atomically on the backend.
    final response = await _client.send<CustomerCheckout>(
      ApiRequest(
        method: 'POST',
        path: '/v1/mobile/customer/checkout',
        body: {
          'cartId': cartId,
          'addressId': addressId,
          if (deliveryNotes != null && deliveryNotes.isNotEmpty)
            'deliveryNotes': deliveryNotes,
          if (tipCents != null) 'tipCents': tipCents,
        },
      ),
      decoder: CustomerCheckout.fromJson,
    );
    return response.data;
  }
}

/// Driver-specific wrapper around the delivery lifecycle endpoints.
class DriverMobileApi {
  const DriverMobileApi(this._client);

  final ApiClient _client;

  Future<DriverBootstrap> bootstrap() async {
    final response = await _client.send<DriverBootstrap>(
      const ApiRequest(method: 'GET', path: '/v1/mobile/driver/bootstrap'),
      decoder: DriverBootstrap.fromJson,
    );
    return response.data;
  }

  Future<DriverJobSummary> acceptDelivery(String deliveryId) {
    return _deliveryAction('/v1/mobile/driver/deliveries/$deliveryId/accept');
  }

  Future<DriverJobSummary> pickupDelivery(String deliveryId) {
    return _deliveryAction('/v1/mobile/driver/deliveries/$deliveryId/pickup');
  }

  Future<DriverJobSummary> completeDelivery(String deliveryId) {
    return _deliveryAction('/v1/mobile/driver/deliveries/$deliveryId/complete');
  }

  Future<DriverJobSummary> _deliveryAction(String path) async {
    final response = await _client.send<DriverJobSummary>(
      ApiRequest(method: 'POST', path: path),
      decoder: (rawBody) {
        // Driver mutation routes wrap the refreshed assignment under `job`, so
        // unwrap it once here and keep the rest of the app model-centric.
        final body = rawBody as Map<Object?, Object?>;
        return DriverJobSummary.fromJson(body['job']);
      },
    );
    return response.data;
  }
}
