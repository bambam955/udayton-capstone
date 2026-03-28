import 'dart:math' as math;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RouteSimulationFrame {
  const RouteSimulationFrame({
    required this.position,
    required this.bearing,
    required this.progress,
  });

  final Position position;
  final double bearing;
  final double progress;
}

List<Position> sampleRouteGeometry(
  List<Position> geometry, {
  double stepMeters = 35,
}) {
  if (geometry.isEmpty) {
    return const [];
  }
  if (geometry.length == 1) {
    return List<Position>.from(geometry);
  }

  final samples = <Position>[geometry.first];
  for (var index = 0; index < geometry.length - 1; index += 1) {
    final start = geometry[index];
    final end = geometry[index + 1];
    final segmentDistance = distanceBetweenPositions(start, end);
    if (segmentDistance <= 0) {
      continue;
    }

    final segmentStepCount = math.max(1, (segmentDistance / stepMeters).ceil());
    for (var step = 1; step <= segmentStepCount; step += 1) {
      samples.add(interpolatePosition(start, end, step / segmentStepCount));
    }
  }

  if (samples.length == 1) {
    samples.add(geometry.last);
  }
  return samples;
}

RouteSimulationFrame frameForProgress(
    List<Position> geometry, double progress) {
  if (geometry.isEmpty) {
    throw ArgumentError.value(geometry, 'geometry', 'Cannot be empty');
  }
  if (geometry.length == 1) {
    return RouteSimulationFrame(
      position: geometry.first,
      bearing: 0,
      progress: progress.clamp(0.0, 1.0),
    );
  }

  final normalizedProgress = progress.clamp(0.0, 1.0);
  final totalDistance = routeDistanceMeters(geometry);
  if (totalDistance <= 0) {
    final fallbackBearing =
        bearingBetweenPositions(geometry.first, geometry.last);
    return RouteSimulationFrame(
      position: geometry.last,
      bearing: fallbackBearing,
      progress: normalizedProgress,
    );
  }

  final targetDistance = totalDistance * normalizedProgress;
  var traversedDistance = 0.0;

  for (var index = 0; index < geometry.length - 1; index += 1) {
    final start = geometry[index];
    final end = geometry[index + 1];
    final segmentDistance = distanceBetweenPositions(start, end);
    if (segmentDistance <= 0) {
      continue;
    }

    final nextDistance = traversedDistance + segmentDistance;
    final isLastSegment = index == geometry.length - 2;
    if (targetDistance <= nextDistance || isLastSegment) {
      final localProgress =
          ((targetDistance - traversedDistance) / segmentDistance)
              .clamp(0.0, 1.0);
      return RouteSimulationFrame(
        position: interpolatePosition(start, end, localProgress),
        bearing: bearingBetweenPositions(start, end),
        progress: normalizedProgress,
      );
    }

    traversedDistance = nextDistance;
  }

  final fallbackBearing =
      bearingBetweenPositions(geometry[geometry.length - 2], geometry.last);
  return RouteSimulationFrame(
    position: geometry.last,
    bearing: fallbackBearing,
    progress: normalizedProgress,
  );
}

double routeDistanceMeters(List<Position> geometry) {
  if (geometry.length < 2) {
    return 0;
  }
  var distance = 0.0;
  for (var index = 0; index < geometry.length - 1; index += 1) {
    distance += distanceBetweenPositions(geometry[index], geometry[index + 1]);
  }
  return distance;
}

double distanceBetweenPositions(Position from, Position to) {
  const earthRadiusMeters = 6371000.0;
  final lat1 = _degreesToRadians(from.lat.toDouble());
  final lat2 = _degreesToRadians(to.lat.toDouble());
  final deltaLat = lat2 - lat1;
  final deltaLng = _degreesToRadians(to.lng.toDouble() - from.lng.toDouble());

  final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(deltaLng / 2) *
          math.sin(deltaLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

double bearingBetweenPositions(Position from, Position to) {
  final lat1 = _degreesToRadians(from.lat.toDouble());
  final lat2 = _degreesToRadians(to.lat.toDouble());
  final deltaLng = _degreesToRadians(to.lng.toDouble() - from.lng.toDouble());

  final y = math.sin(deltaLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);
  var bearing = _radiansToDegrees(math.atan2(y, x));
  if (bearing < 0) {
    bearing += 360;
  }
  return bearing;
}

Position interpolatePosition(Position from, Position to, double t) {
  final clamped = t.clamp(0.0, 1.0);
  final lng =
      from.lng.toDouble() + (to.lng.toDouble() - from.lng.toDouble()) * clamped;
  final lat =
      from.lat.toDouble() + (to.lat.toDouble() - from.lat.toDouble()) * clamped;
  return Position(lng, lat);
}

double _degreesToRadians(double degrees) => degrees * math.pi / 180;

double _radiansToDegrees(double radians) => radians * 180 / math.pi;
