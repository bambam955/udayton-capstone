import 'package:bizrush_shared/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveApiBaseUrl', () {
    test('prefers the configured BIZRUSH_API_BASE_URL value', () {
      final baseUrl = resolveApiBaseUrl(
        configuredBaseUrl: 'http://192.168.1.25:3000',
        targetPlatform: TargetPlatform.android,
      );

      expect(baseUrl, 'http://192.168.1.25:3000');
    });

    test('uses the Android emulator host alias by default', () {
      final baseUrl = resolveApiBaseUrl(
        targetPlatform: TargetPlatform.android,
      );

      expect(baseUrl, 'http://10.0.2.2:3000');
    });

    test('keeps localhost for non-Android local targets', () {
      final iOSUrl = resolveApiBaseUrl(
        targetPlatform: TargetPlatform.iOS,
      );
      final desktopUrl = resolveApiBaseUrl(
        targetPlatform: TargetPlatform.macOS,
      );

      expect(iOSUrl, 'http://localhost:3000');
      expect(desktopUrl, 'http://localhost:3000');
    });

    test('keeps localhost for web development runs', () {
      final baseUrl = resolveApiBaseUrl(
        isWeb: true,
        targetPlatform: TargetPlatform.android,
      );

      expect(baseUrl, 'http://localhost:3000');
    });
  });
}
