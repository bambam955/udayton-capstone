import 'package:bizrush_driver/ui/screens/home/driver_route_simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  test('sampleRouteGeometry returns non-empty ordered coordinates', () {
    final route = sampleRouteGeometry(
      [
        Position(-84.2000, 39.7500),
        Position(-84.1000, 39.7500),
      ],
      stepMeters: 1000,
    );

    expect(route, isNotEmpty);
    expect(route.first.lng, closeTo(-84.2000, 0.000001));
    expect(route.last.lng, closeTo(-84.1000, 0.000001));

    for (var index = 1; index < route.length; index += 1) {
      expect(route[index].lng, greaterThanOrEqualTo(route[index - 1].lng));
    }
  });

  test('frameForProgress reaches destination at progress 1.0', () {
    final route = sampleRouteGeometry(
      [
        Position(-84.2500, 39.7000),
        Position(-84.2000, 39.7300),
        Position(-84.1500, 39.7600),
      ],
      stepMeters: 800,
    );

    final endFrame = frameForProgress(route, 1.0);

    expect(endFrame.progress, 1.0);
    expect(endFrame.position.lng, closeTo(route.last.lng, 0.000001));
    expect(endFrame.position.lat, closeTo(route.last.lat, 0.000001));
  });

  test('bearingBetweenPositions returns valid directional bearing', () {
    final bearing = bearingBetweenPositions(
      Position(-84.2000, 39.7500),
      Position(-84.1000, 39.7500),
    );

    expect(bearing, inInclusiveRange(0, 360));
    expect(bearing, inInclusiveRange(80, 100));
  });
}
