import 'package:flutter/foundation.dart';

/// Resolves the local development API URL for host-run Flutter apps.
///
/// Android emulators cannot reach services on the host machine through
/// `localhost`, so they need the special `10.0.2.2` alias instead. All other
/// current local targets can keep using `localhost` unless a caller supplies an
/// explicit override through `--dart-define`.
String resolveLocalApiBaseUrl({
  String configuredBaseUrl = '',
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
