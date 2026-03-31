import 'package:bizrush_driver/ui/screens/home/driver_geocoding_service.dart';
import 'package:bizrush_driver/ui/screens/home/driver_home_shell.dart';
import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('geocodes dropoff coordinates before opening the dropoff map',
      (WidgetTester tester) async {
    final apiClient = _FakeDriverHomeApiClient();
    final geocodingService = _FakeDriverGeocodingService();

    await tester.pumpWidget(
      MaterialApp(
        home: DriverHomeShell(
          session: ApiSession(
            accessToken: 'driver-token',
            expiresAt: DateTime.utc(2099, 1, 1),
            user: const AuthUser(
              id: 'driver-1',
              role: ApiUserRole.driver,
              email: 'driver@example.com',
            ),
          ),
          authApi: AuthApi(apiClient, InMemorySessionStore()),
          driverApi: DriverMobileApi(apiClient),
          resourceApi: ResourceApi(apiClient),
          onSignedOut: () {},
          geocodingService: geocodingService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    navBar.onDestinationSelected?.call(2);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-confirm-pickup-del-1')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('driver-map-destination-detail')), findsOneWidget);
    expect(find.textContaining('35.3000'), findsOneWidget);
    expect(find.textContaining('-80.7000'), findsOneWidget);
    expect(geocodingService.requests, contains('1 Elm St'));
  });

  testWidgets('geocodes pickup coordinates before opening the pickup map',
      (WidgetTester tester) async {
    final apiClient = _FakeDriverHomeApiClient(
      includePickupCoordinates: false,
      initialStage: 'available',
    );
    final geocodingService = _FakeDriverGeocodingService();

    await tester.pumpWidget(
      MaterialApp(
        home: DriverHomeShell(
          session: ApiSession(
            accessToken: 'driver-token',
            expiresAt: DateTime.utc(2099, 1, 1),
            user: const AuthUser(
              id: 'driver-1',
              role: ApiUserRole.driver,
              email: 'driver@example.com',
            ),
          ),
          authApi: AuthApi(apiClient, InMemorySessionStore()),
          driverApi: DriverMobileApi(apiClient),
          resourceApi: ResourceApi(apiClient),
          onSignedOut: () {},
          geocodingService: geocodingService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    navBar.onDestinationSelected?.call(1);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-accept-del-1')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('driver-map-destination-detail')), findsOneWidget);
    expect(find.text('100 Main St'), findsOneWidget);
    expect(geocodingService.requests, contains('100 Main St'));
  });
}

class _FakeDriverGeocodingService extends DriverGeocodingService {
  final List<String> requests = <String>[];

  @override
  Future<DriverGeocodedPoint?> geocodeAddress(String addressLine) async {
    requests.add(addressLine);
    return switch (addressLine) {
      '100 Main St' => const DriverGeocodedPoint(lat: 35.25, lng: -80.81),
      '1 Elm St' => const DriverGeocodedPoint(lat: 35.3, lng: -80.7),
      _ => null,
    };
  }
}

class _FakeDriverHomeApiClient implements ApiClient {
  _FakeDriverHomeApiClient({
    this.includePickupCoordinates = true,
    String initialStage = 'assigned',
  }) : _stage = initialStage;

  final bool includePickupCoordinates;
  String _stage = 'assigned';

  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    ApiDecoder<T>? decoder,
  }) async {
    final raw = switch ('${request.method} ${request.path}') {
      'GET /v1/mobile/driver/bootstrap' => _bootstrapJson(_stage,
          includePickupCoordinates: includePickupCoordinates),
      'POST /v1/mobile/driver/deliveries/del-1/accept' =>
        _transition('assigned'),
      'POST /v1/mobile/driver/deliveries/del-1/pickup' =>
        _transition('out_for_delivery'),
      'GET /v1/driver-earnings' => <String, Object?>{'data': <Object?>[]},
      'GET /v1/driver-payouts' => <String, Object?>{'data': <Object?>[]},
      _ => throw StateError(
          'Unexpected request: ${request.method} ${request.path}'),
    };

    final data = decoder == null ? raw as T : decoder(raw);
    return ApiResponse<T>(statusCode: 200, data: data);
  }

  Map<String, Object?> _transition(String stage) {
    _stage = stage;
    return <String, Object?>{
      'job':
          _jobJson(stage, includePickupCoordinates: includePickupCoordinates),
    };
  }
}

Map<String, Object?> _bootstrapJson(String stage,
    {required bool includePickupCoordinates}) {
  return <String, Object?>{
    'driver': <String, Object?>{
      'id': 'driver-1',
      'email': 'driver@example.com',
      'fullName': 'Driver Test',
      'status': 'ONLINE',
    },
    'availableJobs': stage == 'available'
        ? <Object?>[
            _jobJson(stage, includePickupCoordinates: includePickupCoordinates)
          ]
        : <Object?>[],
    'activeJobs': stage == 'assigned' || stage == 'out_for_delivery'
        ? <Object?>[
            _jobJson(stage, includePickupCoordinates: includePickupCoordinates)
          ]
        : <Object?>[],
    'completedJobs': <Object?>[],
    'supportTickets': <Object?>[],
    'earningsSummary': <String, Object?>{
      'todayGrossCents': 0,
      'tipsCents': 0,
      'bonusCents': 0,
      'nextPayoutLabel': 'Tomorrow 9:00 AM',
    },
  };
}

Map<String, Object?> _jobJson(String stage,
    {bool includePickupCoordinates = true}) {
  return <String, Object?>{
    'deliveryId': 'del-1',
    'orderId': 'ord-1',
    'title': 'Downtown Pantry Run',
    'pickupLocationId': 'loc-1',
    'pickupName': 'Downtown Market',
    'pickupAddressLine': '100 Main St',
    'pickupLat': includePickupCoordinates ? 35.2271 : null,
    'pickupLng': includePickupCoordinates ? -80.8431 : null,
    'dropoffName': 'Northside Deli',
    'dropoffAddressLine': '1 Elm St',
    'zone': 'Uptown',
    'payoutEstimateCents': 1450,
    'distanceMiles': 4.2,
    'etaMinutes': 18,
    'stage': stage,
    'detailLines': <Object?>[
      'Pickup window: ASAP',
      'Proof required: Photo',
    ],
    'basePayCents': 800,
    'tipCents': 450,
  };
}
