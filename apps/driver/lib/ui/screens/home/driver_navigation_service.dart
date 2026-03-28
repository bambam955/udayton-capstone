import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

typedef DriverLaunchUrl = Future<bool> Function(Uri url, LaunchMode launchMode);

Future<bool> _defaultLaunchUrl(Uri url, LaunchMode launchMode) {
  return launchUrl(url, mode: launchMode);
}

class DriverNavigationDestination {
  const DriverNavigationDestination({
    required this.label,
    required this.lat,
    required this.lng,
  });

  final String label;
  final double lat;
  final double lng;
}

class DriverNavigationService {
  const DriverNavigationService({this.launchUrlCallback = _defaultLaunchUrl});

  final DriverLaunchUrl launchUrlCallback;

  Future<bool> navigateTo(DriverNavigationDestination destination) async {
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
      return [buildGoogleMapsWebUri(destination)];
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => [
          buildGoogleNavigationUri(destination),
          buildGoogleMapsWebUri(destination),
        ],
      TargetPlatform.iOS => [
          buildAppleMapsUri(destination),
          buildGoogleMapsWebUri(destination),
        ],
      _ => [buildGoogleMapsWebUri(destination)],
    };
  }

  static Uri buildGoogleNavigationUri(DriverNavigationDestination destination) {
    return Uri.parse(
      'google.navigation:q=${destination.lat},${destination.lng}',
    );
  }

  static Uri buildAppleMapsUri(DriverNavigationDestination destination) {
    return Uri.https('maps.apple.com', '/', {
      'daddr': '${destination.lat},${destination.lng}',
    });
  }

  static Uri buildGoogleMapsWebUri(DriverNavigationDestination destination) {
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${destination.lat},${destination.lng}',
    });
  }
}
