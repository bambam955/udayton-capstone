import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

typedef DriverLaunchUrl = Future<bool> Function(Uri url, LaunchMode launchMode);

Future<bool> _defaultLaunchUrl(Uri url, LaunchMode launchMode) {
  return launchUrl(url, mode: launchMode);
}

/// Destination descriptor used for external navigation launches.
class DriverNavigationDestination {
  const DriverNavigationDestination({
    required this.label,
    this.lat,
    this.lng,
    this.query,
  });

  final String label;
  final double? lat;
  final double? lng;
  final String? query;
}

/// Platform-aware launcher for external turn-by-turn navigation.
class DriverNavigationService {
  const DriverNavigationService({this.launchUrlCallback = _defaultLaunchUrl});

  final DriverLaunchUrl launchUrlCallback;

  Future<bool> navigateTo(DriverNavigationDestination destination) async {
    // Try the most native option first, then fall back to a web URL if the
    // platform cannot handle the preferred scheme.
    for (final uri in candidateUris(destination)) {
      final launched =
          await launchUrlCallback(uri, LaunchMode.externalApplication);
      if (launched) {
        return true;
      }
    }
    return false;
  }

  List<Uri> candidateUris(DriverNavigationDestination destination) {
    if (kIsWeb) {
      return <Uri>[buildGoogleMapsWebUri(destination)];
    }

    // Candidate order matters: each platform gets its preferred deep link
    // first, then a more portable web fallback.
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => <Uri>[
          buildGoogleNavigationUri(destination),
          buildGoogleMapsWebUri(destination),
        ],
      TargetPlatform.iOS => <Uri>[
          buildAppleMapsUri(destination),
          buildGoogleMapsWebUri(destination),
        ],
      _ => <Uri>[buildGoogleMapsWebUri(destination)],
    };
  }

  static Uri buildGoogleNavigationUri(DriverNavigationDestination destination) {
    final target = _targetValue(destination, encodeForNavigation: true);
    return Uri.parse('google.navigation:q=$target');
  }

  static Uri buildAppleMapsUri(DriverNavigationDestination destination) {
    return Uri.https('maps.apple.com', '/', <String, String>{
      'daddr': _targetValue(destination),
    });
  }

  static Uri buildGoogleMapsWebUri(DriverNavigationDestination destination) {
    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'destination': _targetValue(destination),
    });
  }

  static String _targetValue(
    DriverNavigationDestination destination, {
    bool encodeForNavigation = false,
  }) {
    if (destination.lat != null && destination.lng != null) {
      // Coordinates are preferred whenever available because they avoid
      // ambiguity in mall/storefront or apartment-address destinations.
      return '${destination.lat},${destination.lng}';
    }

    final value = destination.query ?? destination.label;
    return encodeForNavigation ? Uri.encodeComponent(value) : value;
  }
}
