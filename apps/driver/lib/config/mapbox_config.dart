import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get mapboxAccessToken {
  try {
    // `dotenv` throws if the file was never loaded, so keep token lookup
    // defensive and let the map UI fall back gracefully when unavailable.
    return dotenv.env['ACCESS_TOKEN'] ?? '';
  } catch (_) {
    return '';
  }
}

bool get hasMapboxAccessToken => mapboxAccessToken.trim().isNotEmpty;

bool get isMapboxPlatformSupported {
  if (kIsWeb) {
    // The current map screen relies on native Mapbox support and intentionally
    // falls back to external navigation links on the web.
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}
