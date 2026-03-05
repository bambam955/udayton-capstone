import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizrush/main.dart';

void main() {
  testWidgets('Main nav shows tab-specific content and cart works on Home', (
    WidgetTester tester,
  ) async {
    Future<void> selectMainTab(int index) async {
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navBar.onDestinationSelected?.call(index);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-logo')), findsOneWidget);
    expect(find.byKey(const Key('main-tab-home')), findsOneWidget);
    expect(find.text('Recommended items'), findsOneWidget);

    await selectMainTab(2);
    expect(find.byKey(const Key('main-tab-orders')), findsOneWidget);
    expect(find.byKey(const Key('order-card-ord_1001')), findsOneWidget);
    await tester.tap(find.byKey(const Key('order-view-ord_1001')));
    await tester.pumpAndSettle();
    expect(find.text('Order demo details'), findsOneWidget);
    expect(find.byKey(const Key('details-sheet-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('details-sheet-close')));
    await tester.pumpAndSettle();
    expect(find.text('Order demo details'), findsNothing);

    await selectMainTab(3);
    expect(find.byKey(const Key('main-tab-support')), findsOneWidget);
    expect(find.byKey(const Key('support-ticket-tk_771')), findsOneWidget);

    await selectMainTab(4);
    expect(find.byKey(const Key('main-tab-account')), findsOneWidget);
    expect(find.text('Connected stores'), findsOneWidget);

    await selectMainTab(0);

    await tester.tap(find.byKey(const Key('store-walmart_eastgate')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('add-to-cart-item_201')));
    await tester.tap(find.byKey(const Key('add-to-cart-item_201')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart-line-item_201')), findsOneWidget);
    expect(find.byKey(const Key('cart-totals-card')), findsOneWidget);
  });
}
