import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/mapbox_config.dart';

typedef DriverHttpGet = Future<http.Response> Function(Uri uri);

Future<http.Response> _defaultHttpGet(Uri uri) {
  return http.get(uri);
}

class DriverGeocodedPoint {
  const DriverGeocodedPoint({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;
}

class DriverGeocodingService {
  const DriverGeocodingService({this.httpGet = _defaultHttpGet});

  final DriverHttpGet httpGet;

  Future<DriverGeocodedPoint?> geocodeAddress(String addressLine) async {
    final trimmedAddress = addressLine.trim();
    if (trimmedAddress.isEmpty || !hasMapboxAccessToken) {
      return null;
    }

    final uri = Uri.https('api.mapbox.com', '/search/geocode/v6/forward', {
      'q': trimmedAddress,
      'limit': '1',
      'access_token': mapboxAccessToken,
    });

    final response = await httpGet(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Geocoding request failed: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final features = payload['features'] as List<dynamic>? ?? const <dynamic>[];
    if (features.isEmpty) {
      return null;
    }

    final feature = features.first as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>?;
    final coordinates =
        geometry?['coordinates'] as List<dynamic>? ?? const <dynamic>[];
    if (coordinates.length < 2) {
      return null;
    }

    return DriverGeocodedPoint(
      lat: (coordinates[1] as num).toDouble(),
      lng: (coordinates[0] as num).toDouble(),
    );
  }
}
