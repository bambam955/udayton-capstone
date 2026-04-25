import 'package:flutter/foundation.dart';

/// Compile-time variable used by mobile builds to target a deployed API.
const _configuredApiBaseUrl = String.fromEnvironment('BIZRUSH_API_BASE_URL');

/// Resolves the API URL shared by all Flutter app builds.
///
/// Production/demo builds should pass `BIZRUSH_API_BASE_URL` through
/// `--dart-define`. Local Android emulator builds fall back to the host-machine
/// alias so the app can reach the API published on the host's port 3000.
String resolveApiBaseUrl({
  String configuredBaseUrl = _configuredApiBaseUrl,
  bool isWeb = kIsWeb,
  TargetPlatform? targetPlatform,
}) {
  if (configuredBaseUrl.isNotEmpty) {
    return configuredBaseUrl;
  }

  final platform = isWeb ? null : (targetPlatform ?? defaultTargetPlatform);
  final host = platform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  return 'http://$host:3000';
}
