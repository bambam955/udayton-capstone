import 'package:bizrush_shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme.light uses material3 and shared base colors', () {
    final theme = AppTheme.light();
    final expectedPrimary = ColorScheme.fromSeed(
      seedColor: const Color(0xFF129488),
    ).primary;

    expect(theme.useMaterial3, isTrue);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F7F5));
    expect(theme.colorScheme.primary, expectedPrimary);
    expect(theme.navigationBarTheme.height, 68);
  });
}
