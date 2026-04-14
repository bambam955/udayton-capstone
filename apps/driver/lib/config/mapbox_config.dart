import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// CI and release builds can inject the token without relying on a bundled env
// asset, which keeps secrets out of git while still supporting local overrides.
const _compileTimeAccessToken = String.fromEnvironment('ACCESS_TOKEN');

String get mapboxAccessToken {
  final compileTimeAccessToken = _compileTimeAccessToken.trim();
  if (compileTimeAccessToken.isNotEmpty) {
    return compileTimeAccessToken;
  }

  try {
    // `dotenv` throws if the file was never loaded, so keep token lookup
    // defensive and let the map UI fall back gracefully when unavailable.
    return dotenv.env['ACCESS_TOKEN']?.trim() ?? '';
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
