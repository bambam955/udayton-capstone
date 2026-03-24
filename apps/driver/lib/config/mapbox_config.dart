import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get mapboxAccessToken => dotenv.env['ACCESS_TOKEN'] ?? '';

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
