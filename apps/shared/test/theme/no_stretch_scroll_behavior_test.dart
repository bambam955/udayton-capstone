import 'package:bizrush_shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoStretchScrollBehavior returns clamping physics', (
    WidgetTester tester,
  ) async {
    const behavior = NoStretchScrollBehavior();
    late ScrollPhysics physics;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            physics = behavior.getScrollPhysics(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(physics, isA<ClampingScrollPhysics>());
  });
}
