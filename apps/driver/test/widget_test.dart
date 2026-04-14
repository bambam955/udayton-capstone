import 'package:bizrush_driver/config/driver_app_dependencies.dart';
import 'package:bizrush_driver/main.dart';
import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Driver app authenticates and runs delivery workflow', (
    WidgetTester tester,
  ) async {
    final sessionStore = InMemorySessionStore();
    final apiClient = _FakeDriverApiClient();
    final dependencies = DriverAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      driverApi: DriverMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );

    Future<void> selectDriverTab(int index) async {
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navBar.onDestinationSelected?.call(index);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(MyApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'Sign in or create an account to manage live offers, deliveries, support, and earnings.'),
        findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('driver-auth-email')), 'driver@example.com');
    await tester.enterText(
        find.byKey(const Key('driver-auth-password')), 'secret');
    await tester.tap(find.byKey(const Key('driver-auth-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-logo')), findsOneWidget);
    expect(find.byKey(const Key('driver-tab-home')), findsOneWidget);

    await selectDriverTab(1);
    expect(find.byKey(const Key('driver-tab-nearby')), findsOneWidget);
    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-view-details-del-1')));
    await tester.pumpAndSettle();
    expect(find.text('Delivery details'), findsOneWidget);
    await tester.tap(find.byKey(const Key('details-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-accept-del-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-map-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsNothing);

    await selectDriverTab(2);
    expect(find.byKey(const Key('driver-tab-deliveries')), findsOneWidget);
    expect(find.byKey(const Key('driver-delivery-card-del-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-open-map-del-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-map-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-confirm-pickup-del-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-map-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-complete-delivery-del-1')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-complete-delivery-del-1')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const Key('driver-deliveries-filter-Completed')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-delivery-card-del-1')), findsOneWidget);

    await selectDriverTab(3);
    expect(find.byKey(const Key('driver-tab-earnings')), findsOneWidget);
    expect(find.byKey(const Key('driver-earnings-row-del-1')), findsOneWidget);
    expect(find.byKey(const Key('driver-payout-row-payout-1')), findsOneWidget);

    await selectDriverTab(4);
    expect(find.byKey(const Key('driver-tab-support')), findsOneWidget);
    expect(
        find.byKey(const Key('driver-support-case-ticket-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-support-quick-pickup')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('driver-support-case-ticket-2')), findsOneWidget);
  });

  testWidgets('Driver app can sign up from the auth screen', (
    WidgetTester tester,
  ) async {
    final sessionStore = InMemorySessionStore();
    final apiClient = _FakeDriverApiClient();
    final dependencies = DriverAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      driverApi: DriverMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );

    await tester.pumpWidget(MyApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('driver-auth-full-name')),
      'New Driver',
    );
    await tester.enterText(
      find.byKey(const Key('driver-auth-phone')),
      '555-202-0006',
    );
    await tester.enterText(
      find.byKey(const Key('driver-auth-email')),
      'newdriver@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('driver-auth-password')),
      'secret',
    );
    await tester.ensureVisible(find.byKey(const Key('driver-auth-submit')));
    await tester.tap(find.byKey(const Key('driver-auth-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-logo')), findsOneWidget);
    expect(apiClient.lastSignupBody, <String, Object?>{
      'role': 'driver',
      'email': 'newdriver@example.com',
      'password': 'secret',
      'fullName': 'New Driver',
      'phone': '555-202-0006',
      'deviceInfo': 'driver-app',
    });
  });

  testWidgets('Driver app toggles online status and refreshes shared offers', (
    WidgetTester tester,
  ) async {
    final sessionStore = InMemorySessionStore();
    final apiClient = _FakeDriverApiClient();
    final dependencies = DriverAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      driverApi: DriverMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );

    Future<void> selectDriverTab(int index) async {
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navBar.onDestinationSelected?.call(index);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(MyApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('driver-auth-email')),
      'driver@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('driver-auth-password')),
      'secret',
    );
    await tester.tap(find.byKey(const Key('driver-auth-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-status-subtitle')), findsOneWidget);
    expect(find.text('ONLINE'), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-availability-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('OFFLINE'), findsOneWidget);
    await selectDriverTab(1);
    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsNothing);

    await tester.tap(find.byKey(const Key('driver-availability-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('ONLINE'), findsOneWidget);
    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsOneWidget);
  });

  testWidgets('Driver app manually refreshes nearby offers', (
    WidgetTester tester,
  ) async {
    final sessionStore = InMemorySessionStore();
    final apiClient = _FakeDriverApiClient();
    final dependencies = DriverAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      driverApi: DriverMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );
    const refreshDelay = Duration(milliseconds: 200);

    Future<void> selectDriverTab(int index) async {
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navBar.onDestinationSelected?.call(index);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(MyApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('driver-auth-email')),
      'driver@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('driver-auth-password')),
      'secret',
    );
    await tester.tap(find.byKey(const Key('driver-auth-submit')));
    await tester.pumpAndSettle();

    await selectDriverTab(1);

    expect(find.byKey(const Key('driver-nearby-refresh')), findsOneWidget);
    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsOneWidget);
    expect(find.byKey(const Key('driver-nearby-card-del-2')), findsNothing);

    apiClient.bootstrapDelay = refreshDelay;
    apiClient.replaceAvailableJobs(
      <Map<String, Object?>>[
        _jobJson(
          'available',
          deliveryId: 'del-2',
          orderId: 'ord-2',
          title: 'Airport Express Run',
          pickupName: 'Airport Market',
          pickupAddressLine: '200 Skyway Blvd',
          dropoffName: 'Southside Cafe',
          dropoffAddressLine: '22 Cedar Ave',
          zone: 'Airport',
          payoutEstimateCents: 1825,
          distanceMiles: 6.1,
          etaMinutes: 24,
        ),
      ],
    );

    final enabledRefreshButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('driver-nearby-refresh')),
    );
    expect(enabledRefreshButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('driver-nearby-refresh')));
    await tester.pump();

    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsOneWidget);
    expect(
        find.byKey(const Key('driver-nearby-refresh-spinner')), findsOneWidget);

    final disabledRefreshButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('driver-nearby-refresh')),
    );
    expect(disabledRefreshButton.onPressed, isNull);

    await tester.pump(refreshDelay);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-nearby-card-del-1')), findsNothing);
    expect(find.byKey(const Key('driver-nearby-card-del-2')), findsOneWidget);
    expect(find.text('Airport Express Run'), findsOneWidget);
    expect(
        find.byKey(const Key('driver-nearby-refresh-spinner')), findsNothing);

    final reenabledRefreshButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('driver-nearby-refresh')),
    );
    expect(reenabledRefreshButton.onPressed, isNotNull);
  });
}

class _FakeDriverApiClient implements ApiClient {
  String _stage = 'available';
  String _driverStatus = 'ONLINE';
  Duration bootstrapDelay = Duration.zero;
  Map<String, Object?>? lastSignupBody;
  List<Map<String, Object?>> _availableJobs = <Map<String, Object?>>[
    _jobJson('available'),
  ];
  final List<Map<String, Object?>> _supportTickets = <Map<String, Object?>>[
    <String, Object?>{
      'ticketId': 'ticket-1',
      'deliveryId': 'del-1',
      'title': 'Pickup readiness mismatch',
      'status': 'OPEN',
      'summary': 'Store marked ready but items were still being staged.',
    },
  ];

  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    ApiDecoder<T>? decoder,
  }) async {
    final requestKey = '${request.method} ${request.path}';

    if (request.method == 'POST' && request.path == '/v1/auth/signup') {
      lastSignupBody = Map<String, Object?>.from(
        request.body! as Map<Object?, Object?>,
      );
    }

    late final Object? raw;
    if (requestKey == 'GET /v1/mobile/driver/bootstrap') {
      if (bootstrapDelay > Duration.zero) {
        await Future<void>.delayed(bootstrapDelay);
      }
      raw = _bootstrapJson(
        _stage,
        _supportTickets,
        _driverStatus,
        _availableJobs,
      );
    } else {
      raw = switch (requestKey) {
        'POST /v1/auth/signup' => <String, Object?>{
            'accessToken': 'driver-signup-token',
            'expiresAt': '2099-01-01T00:00:00.000Z',
            'user': <String, Object?>{
              'id': 'driver-2',
              'role': 'driver',
              'email': 'newdriver@example.com',
            },
          },
        'POST /v1/auth/login' => <String, Object?>{
            'accessToken': 'driver-token',
            'expiresAt': '2099-01-01T00:00:00.000Z',
            'user': <String, Object?>{
              'id': 'driver-1',
              'role': 'driver',
              'email': 'driver@example.com',
            },
          },
        'POST /v1/mobile/driver/deliveries/del-1/accept' =>
          _transition('assigned'),
        'POST /v1/mobile/driver/deliveries/del-1/pickup' =>
          _transition('out_for_delivery'),
        'POST /v1/mobile/driver/deliveries/del-1/complete' =>
          _transition('delivered'),
        'PATCH /v1/drivers/driver-1' => _updateDriverStatus(request.body),
        'GET /v1/driver-earnings' => <String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'earning_id': 'earn-1',
                'driver_id': 'driver-1',
                'delivery_id': 'del-1',
                'base_pay_cents': 800,
                'bonus_cents': 200,
                'tip_cents': 450,
                'total_pay_cents': 1450,
                'currency': 'USD',
                'status': 'POSTED',
              },
            ],
          },
        'GET /v1/driver-payouts' => <String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'payout_id': 'payout-1',
                'driver_id': 'driver-1',
                'amount_cents': 1450,
                'currency': 'USD',
                'status': 'PENDING',
                'provider': 'Stripe',
                'provider_ref': 'ref-1',
              },
            ],
          },
        'POST /v1/driver-support-tickets' => _createSupportTicket(),
        _ => throw StateError(
            'Unexpected request: ${request.method} ${request.path}'),
      };
    }

    final data = decoder == null ? raw as T : decoder(raw);
    return ApiResponse<T>(statusCode: 200, data: data);
  }

  void replaceAvailableJobs(List<Map<String, Object?>> jobs) {
    _availableJobs = jobs;
  }

  Map<String, Object?> _transition(String stage) {
    _stage = stage;
    return <String, Object?>{
      'job': _jobJson(stage),
    };
  }

  Map<String, Object?> _updateDriverStatus(Object? rawBody) {
    final body = Map<Object?, Object?>.from(rawBody! as Map<Object?, Object?>);
    _driverStatus = body['status'] as String? ?? _driverStatus;
    return <String, Object?>{
      'data': <String, Object?>{
        'driver_id': 'driver-1',
        'email': 'driver@example.com',
        'phone': '555-202-0001',
        'full_name': 'Driver Test',
        'is_active': true,
        'status': _driverStatus,
      },
    };
  }

  Map<String, Object?> _createSupportTicket() {
    _supportTickets.insert(
      0,
      <String, Object?>{
        'ticketId': 'ticket-2',
        'deliveryId': 'del-1',
        'title': 'Driver requested support',
        'status': 'OPEN',
        'summary': 'Driver requested support from the app.',
      },
    );

    return <String, Object?>{
      'data': <String, Object?>{
        'ticket_id': 'ticket-2',
        'driver_id': 'driver-1',
        'delivery_id': 'del-1',
        'order_id': 'ord-1',
        'issue_type': 'PICKUP_ISSUE',
        'message': 'Driver requested support from the app.',
        'status': 'OPEN',
      },
    };
  }
}

Map<String, Object?> _bootstrapJson(
  String stage,
  List<Map<String, Object?>> supportTickets,
  String driverStatus,
  List<Map<String, Object?>> availableJobs,
) {
  return <String, Object?>{
    'driver': <String, Object?>{
      'id': 'driver-1',
      'email': 'driver@example.com',
      'fullName': 'Driver Test',
      'status': driverStatus,
    },
    'availableJobs': stage == 'available' && driverStatus == 'ONLINE'
        ? <Object?>[...availableJobs]
        : <Object?>[],
    'activeJobs': stage == 'assigned' || stage == 'out_for_delivery'
        ? <Object?>[_jobJson(stage)]
        : <Object?>[],
    'completedJobs':
        stage == 'delivered' ? <Object?>[_jobJson('delivered')] : <Object?>[],
    'supportTickets': supportTickets,
    'earningsSummary': <String, Object?>{
      'todayGrossCents': 1450,
      'tipsCents': 450,
      'bonusCents': 200,
      'nextPayoutLabel': 'Tomorrow 9:00 AM',
    },
  };
}

Map<String, Object?> _jobJson(
  String stage, {
  String deliveryId = 'del-1',
  String orderId = 'ord-1',
  String title = 'Downtown Pantry Run',
  String pickupLocationId = 'loc-1',
  String pickupName = 'Downtown Market',
  String pickupAddressLine = '100 Main St',
  double pickupLat = 35.2271,
  double pickupLng = -80.8431,
  String dropoffName = 'Northside Deli',
  String dropoffAddressLine = '1 Elm St',
  String zone = 'Uptown',
  int payoutEstimateCents = 1450,
  double distanceMiles = 4.2,
  int etaMinutes = 18,
  int basePayCents = 800,
  int tipCents = 450,
}) {
  return <String, Object?>{
    'deliveryId': deliveryId,
    'orderId': orderId,
    'title': title,
    'pickupLocationId': pickupLocationId,
    'pickupName': pickupName,
    'pickupAddressLine': pickupAddressLine,
    'pickupLat': pickupLat,
    'pickupLng': pickupLng,
    'dropoffName': dropoffName,
    'dropoffAddressLine': dropoffAddressLine,
    'zone': zone,
    'payoutEstimateCents': payoutEstimateCents,
    'distanceMiles': distanceMiles,
    'etaMinutes': etaMinutes,
    'stage': stage,
    'detailLines': <Object?>[
      'Pickup window: ASAP',
      'Proof required: Photo',
    ],
    'basePayCents': basePayCents,
    'tipCents': tipCents,
  };
}
