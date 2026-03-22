import 'package:flutter/foundation.dart';

const String mapboxAccessToken = String.fromEnvironment('ACCESS_TOKEN');

bool get hasMapboxAccessToken => mapboxAccessToken.trim().isNotEmpty;

bool get isMapboxPlatformSupported {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}
