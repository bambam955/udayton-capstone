import 'package:bizrush_driver/ui/screens/home/driver_delivery_map_screen.dart';
import 'package:bizrush_driver/ui/screens/home/driver_home_fake_data.dart';
import 'package:bizrush_driver/ui/screens/home/driver_home_models.dart';
import 'package:bizrush_driver/ui/screens/home/driver_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows store address and fallback message when navigation fails',
      (
    WidgetTester tester,
  ) async {
    final service = DriverNavigationService(
      launchUrlCallback: (_, __) async => false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DriverDeliveryMapScreen(
          job: initialDriverJobs.first,
          phase: DriverRoutePhase.toPickup,
          navigationService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('2490 N Fairfield Rd, Beavercreek, OH 45431'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('driver-map-navigate')), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-map-navigate')));
    await tester.pumpAndSettle();

    expect(
      find.text('No navigation app is available for this destination.'),
      findsOneWidget,
    );
  });
}
