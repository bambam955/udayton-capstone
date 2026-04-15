import 'package:bizrush_shared/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveLocalApiBaseUrl', () {
    test('prefers an explicit configured base URL', () {
      final baseUrl = resolveLocalApiBaseUrl(
        configuredBaseUrl: 'http://192.168.1.25:3000',
        targetPlatform: TargetPlatform.android,
      );

      expect(baseUrl, 'http://192.168.1.25:3000');
    });

    test('uses the Android emulator host alias by default', () {
      final baseUrl = resolveLocalApiBaseUrl(
        targetPlatform: TargetPlatform.android,
      );

      expect(baseUrl, 'http://10.0.2.2:3000');
    });

    test('keeps localhost for non-Android local targets', () {
      final iOSUrl = resolveLocalApiBaseUrl(
        targetPlatform: TargetPlatform.iOS,
      );
      final desktopUrl = resolveLocalApiBaseUrl(
        targetPlatform: TargetPlatform.macOS,
      );

      expect(iOSUrl, 'http://localhost:3000');
      expect(desktopUrl, 'http://localhost:3000');
    });

    test('keeps localhost for web development runs', () {
      final baseUrl = resolveLocalApiBaseUrl(
        isWeb: true,
        targetPlatform: TargetPlatform.android,
      );

      expect(baseUrl, 'http://localhost:3000');
    });
  });
}
