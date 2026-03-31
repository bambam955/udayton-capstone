import 'package:bizrush_driver/ui/screens/home/driver_delivery_map_screen.dart';
import 'package:bizrush_driver/ui/screens/home/driver_home_models.dart';
import 'package:bizrush_driver/ui/screens/home/driver_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows pickup address and fallback message when navigation fails',
      (
    WidgetTester tester,
  ) async {
    final service = DriverNavigationService(
      launchUrlCallback: (_, __) async => false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DriverDeliveryMapScreen(
          job: _testJob(),
          phase: DriverRoutePhase.toPickup,
          navigationService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('100 Main St'), findsOneWidget);
    expect(find.byKey(const Key('driver-map-navigate')), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-map-navigate')));
    await tester.pumpAndSettle();

    expect(
      find.text('No navigation app is available for this destination.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'shows pickup-unavailable fallback when pickup coordinates are missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DriverDeliveryMapScreen(
          job: _testJob(
            driverStartLat: null,
            driverStartLng: null,
            pickupLat: null,
            pickupLng: null,
          ),
          phase: DriverRoutePhase.toPickup,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    expect(
      find.text(
          'Precise pickup coordinates are unavailable. External navigation can still open.'),
      findsOneWidget,
    );
  });
}

DriverJob _testJob({
  double? driverStartLat = 35.2471,
  double? driverStartLng = -80.8631,
  double? pickupLat = 35.2271,
  double? pickupLng = -80.8431,
}) {
  return DriverJob(
    id: 'del-1',
    title: 'Downtown Pantry Run',
    driverStartLat: driverStartLat,
    driverStartLng: driverStartLng,
    pickup: 'Downtown Market',
    pickupAddressLine: '100 Main St',
    pickupStoreId: 'loc-1',
    pickupLat: pickupLat,
    pickupLng: pickupLng,
    dropoff: 'Northside Deli',
    dropoffAddressLine: '1 Elm St',
    dropoffLat: null,
    dropoffLng: null,
    zone: 'Uptown',
    payEstimateText: r'$14.50 est.',
    distanceText: '4.2 mi total',
    etaText: '18 min route',
    stage: DeliveryStage.assigned,
    detailLines: <String>['Pickup window: ASAP'],
    gradient: <Color>[const Color(0xFF7FD5CC), const Color(0xFFB6E0AE)],
    basePay: 8,
    tipAmount: 4.5,
    orderId: 'ord-1',
  );
}
