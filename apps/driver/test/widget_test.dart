import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizrush_driver/main.dart';

void main() {
  testWidgets('Driver tabs show distinct content and workflow transitions', (
    WidgetTester tester,
  ) async {
    Future<void> selectDriverTab(int index) async {
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navBar.onDestinationSelected?.call(index);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-logo')), findsOneWidget);
    expect(find.byKey(const Key('driver-tab-home')), findsOneWidget);

    await selectDriverTab(1);
    expect(find.byKey(const Key('driver-tab-nearby')), findsOneWidget);
    expect(
      find.byKey(const Key('driver-nearby-card-drv_job_101')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('driver-view-details-drv_job_101')));
    await tester.pumpAndSettle();
    expect(find.text('Delivery details'), findsOneWidget);
    expect(find.byKey(const Key('details-sheet-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('details-sheet-close')));
    await tester.pumpAndSettle();
    expect(find.text('Delivery details'), findsNothing);

    await tester.tap(find.byKey(const Key('driver-accept-drv_job_101')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    expect(find.byKey(const Key('driver-map-close')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-map-close')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('driver-nearby-card-drv_job_101')),
      findsNothing,
    );

    await selectDriverTab(2);
    expect(find.byKey(const Key('driver-tab-deliveries')), findsOneWidget);
    expect(
      find.byKey(const Key('driver-delivery-card-drv_job_101')),
      findsOneWidget,
    );
    expect(
        find.byKey(const Key('driver-open-map-drv_job_101')), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-open-map-drv_job_101')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-map-close')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('driver-confirm-pickup-drv_job_101')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-map-unavailable')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-map-close')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('driver-complete-delivery-drv_job_101')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('driver-complete-delivery-drv_job_101')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('driver-deliveries-filter-Completed')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('driver-delivery-card-drv_job_101')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('driver-open-map-drv_job_101')), findsNothing);
    expect(find.text('COMPLETED'), findsWidgets);

    await selectDriverTab(3);
    expect(find.byKey(const Key('driver-tab-earnings')), findsOneWidget);
    expect(
      find.byKey(const Key('driver-earnings-row-drv_job_101')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('driver-earnings-today-gross')),
      findsOneWidget,
    );

    await selectDriverTab(4);
    expect(find.byKey(const Key('driver-tab-support')), findsOneWidget);
    expect(find.byKey(const Key('driver-support-case-DS-219')), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-support-quick-pickup')));
    await tester.pumpAndSettle();
    expect(find.text('Pickup issue clicked (demo only)'), findsOneWidget);
  });
}
