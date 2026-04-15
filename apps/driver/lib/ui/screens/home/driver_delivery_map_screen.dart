import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../config/mapbox_config.dart';
import 'driver_home_models.dart';
import 'driver_navigation_service.dart';
import 'driver_route_simulation.dart';

/// Owns full-screen route guidance for accepted and active deliveries.
class DriverDeliveryMapScreen extends StatefulWidget {
  const DriverDeliveryMapScreen({
    super.key,
    required this.job,
    required this.phase,
    this.navigationService = const DriverNavigationService(),
  });

  final DriverJob job;
  final DriverRoutePhase phase;
  final DriverNavigationService navigationService;

  @override
  State<DriverDeliveryMapScreen> createState() =>
      _DriverDeliveryMapScreenState();
}

class _DriverDeliveryMapScreenState extends State<DriverDeliveryMapScreen> {
  static const _simulationTick = Duration(milliseconds: 650);
  static const _overviewPause = Duration(milliseconds: 900);
  static const _followZoom = 16.4;
  static const _followPitch = 52.0;

  static final _cameraPadding = MbxEdgeInsets(
    top: 140,
    left: 60,
    bottom: 220,
    right: 60,
  );

  MapboxMap? _mapboxMap;
  CircleAnnotationManager? _circleAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  CircleAnnotation? _driverMarker;
  bool _styleLoaded = false;
  bool _loadingRoute = false;
  bool _isSimulationRunning = false;
  bool _isSimulationCompleted = false;
  bool _simulationTickInFlight = false;
  int _simulationIndex = 0;
  String? _routeError;
  List<Position> _routeGeometry = const [];
  List<Position> _simulationRoute = const [];
  Timer? _simulationTimer;
  Timer? _simulationStartTimer;

  @override
  void initState() {
    super.initState();
    // Route loading begins immediately so the screen can show progress while
    // the native map view finishes creating itself.
    _loadRouteGeometry();
  }

  @override
  void dispose() {
    _cancelSimulationTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final phaseLabel = _phaseLabel(widget.phase);
    final destination = _navigationDestination;
    final destinationLabel = widget.phase == DriverRoutePhase.toPickup
        ? widget.job.pickup
        : widget.job.dropoff;
    final destinationDetail = widget.phase == DriverRoutePhase.toPickup
        ? widget.job.pickupAddressLine
        : _formatDestinationSubtitle(
            destination, widget.job.dropoffAddressLine);
    final navigateLabel = widget.phase == DriverRoutePhase.toPickup
        ? 'Navigate to store'
        : 'Navigate to dropoff';
    final canReplaySimulation = !_loadingRoute &&
        !_isSimulationRunning &&
        _canRenderMap &&
        _simulationRoute.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery route'),
        actions: [
          IconButton(
            key: const Key('driver-map-close'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _buildMapSurface()),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 10,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phaseLabel,
                            key: const Key('driver-map-phase-label'),
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(destinationLabel, style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            destinationDetail,
                            key: const Key('driver-map-destination-detail'),
                            style: textTheme.bodySmall,
                          ),
                          if (_loadingRoute) ...[
                            const SizedBox(height: 8),
                            const LinearProgressIndicator(),
                          ],
                          if (_routeError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _routeError!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          if (_canRenderMap &&
                              !_loadingRoute &&
                              _simulationRoute.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _simulationStatusLabel,
                                    key: const Key(
                                        'driver-map-simulation-status'),
                                    style: textTheme.bodySmall,
                                  ),
                                ),
                                OutlinedButton(
                                  key: const Key('driver-map-replay'),
                                  onPressed: canReplaySimulation
                                      ? _replaySimulation
                                      : null,
                                  child: const Text('Replay'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('driver-map-navigate'),
                  onPressed: _openExternalNavigation,
                  icon: const Icon(Icons.navigation_rounded),
                  label: Text(navigateLabel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSurface() {
    if (!hasMapboxAccessToken) {
      return const _MapUnavailableCard(
        message:
            'Mapbox token is missing. Add ACCESS_TOKEN to assets/env/local.env or pass --dart-define=ACCESS_TOKEN=...',
      );
    }

    if (!isMapboxPlatformSupported) {
      return const _MapUnavailableCard(
        message: 'Map view is currently supported on Android/iOS only.',
      );
    }

    final missingCoordinatesMessage = _missingCoordinatesMessage;
    if (missingCoordinatesMessage != null) {
      // Missing coordinates should not crash the route UI; the screen still
      // exposes external navigation when precise map rendering is impossible.
      return _MapUnavailableCard(message: missingCoordinatesMessage);
    }

    return MapWidget(
      key: const Key('driver-delivery-map-screen'),
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: CameraOptions(
        center: Point(coordinates: _initialCameraCenter),
        zoom: 11.5,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (_) {
        _styleLoaded = true;
        // The style must be ready before annotations can be drawn, so retry the
        // route render when the callback fires.
        _drawRouteThenStartSimulation();
      },
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _circleAnnotationManager =
        await mapboxMap.annotations.createCircleAnnotationManager();
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();
    _drawRouteThenStartSimulation();
  }

  Future<void> _loadRouteGeometry() async {
    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });

    final missingCoordinatesMessage = _missingCoordinatesMessage;
    if (missingCoordinatesMessage != null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _routeGeometry = const <Position>[];
        _simulationRoute = const <Position>[];
        _simulationIndex = 0;
        _isSimulationRunning = false;
        _isSimulationCompleted = false;
        _routeError = missingCoordinatesMessage;
        _loadingRoute = false;
      });
      return;
    }

    final origin = _routeOrigin;
    final destination = _routeDestination;
    var routeWarning = '';
    List<Position> routeGeometry;

    try {
      routeGeometry = hasMapboxAccessToken
          ? await _requestRouteWithFallback(
              origin: origin, destination: destination)
          : _buildDirectRoute(origin: origin, destination: destination);
    } catch (_) {
      // Fall back to a direct line so the screen can still animate a rough
      // route preview when live directions are unavailable.
      routeGeometry =
          _buildDirectRoute(origin: origin, destination: destination);
      routeWarning = 'Live route unavailable. Using direct-path simulation.';
    }

    var simulationRoute = sampleRouteGeometry(routeGeometry, stepMeters: 160);
    if (simulationRoute.isEmpty) {
      // Sampling can collapse very short routes; use a minimal fallback path so
      // the simulation UI always has something to animate.
      simulationRoute =
          _buildDirectRoute(origin: origin, destination: destination);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _routeGeometry = routeGeometry;
      _simulationRoute = simulationRoute;
      _simulationIndex = 0;
      _isSimulationRunning = false;
      _isSimulationCompleted = false;
      _routeError = routeWarning.isEmpty ? null : routeWarning;
      _loadingRoute = false;
    });

    await _drawRouteThenStartSimulation();
  }

  Future<void> _drawRouteThenStartSimulation() async {
    if (!_isMapReadyForRoute) {
      return;
    }

    // Any route refresh should cancel the prior timers before drawing the new
    // geometry and starting a fresh overview/simulation cycle.
    _cancelSimulationTimers();
    await _drawRouteAndMarkers();
    await _fitRouteOverview();

    _simulationStartTimer = Timer(_overviewPause, () {
      if (!mounted) {
        return;
      }
      _startSimulation(reset: true);
    });
  }

  Future<void> _drawRouteAndMarkers() async {
    final circles = _circleAnnotationManager;
    final polylines = _polylineAnnotationManager;
    if (circles == null || polylines == null || !_isMapReadyForRoute) {
      return;
    }

    final pickupPoint = Point(coordinates: _pickupPosition!);
    final dropoffPosition = _dropoffPosition;

    await circles.deleteAll();
    await polylines.deleteAll();

    if (_routeGeometry.length >= 2) {
      // Draw the polyline only when the route has enough points to form a line.
      await polylines.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: _routeGeometry),
          lineColor: const Color(0xFF1E88E5).toARGB32(),
          lineWidth: 5,
          lineOpacity: 0.9,
        ),
      );
    }

    final markerOptions = <CircleAnnotationOptions>[
      CircleAnnotationOptions(
        geometry: pickupPoint,
        circleColor: const Color(0xFFFF9800).toARGB32(),
        circleRadius: widget.phase == DriverRoutePhase.toPickup ? 8 : 6,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2,
      ),
    ];
    if (dropoffPosition != null) {
      markerOptions.add(
        CircleAnnotationOptions(
          geometry: Point(coordinates: dropoffPosition),
          circleColor: const Color(0xFF2E7D32).toARGB32(),
          circleRadius: widget.phase == DriverRoutePhase.toDropoff ? 8 : 6,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
        ),
      );
    }

    await circles.createMulti(markerOptions);

    final initialDriverPosition =
        _simulationRoute.isEmpty ? _routeOrigin : _simulationRoute.first;
    // Keep a handle to the driver marker so later simulation frames can update
    // it in place instead of recreating annotations every tick.
    _driverMarker = await circles.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: initialDriverPosition),
        circleColor: const Color(0xFF1565C0).toARGB32(),
        circleRadius: 7,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2.5,
      ),
    );
  }

  Future<void> _fitRouteOverview() async {
    final map = _mapboxMap;
    if (map == null || _routeGeometry.isEmpty) {
      return;
    }

    final camera = await map.cameraForCoordinatesPadding(
      _routeGeometry.map((position) => Point(coordinates: position)).toList(),
      CameraOptions(padding: _cameraPadding),
      null,
      null,
      null,
    );
    await map.setCamera(camera);
  }

  Future<void> _startSimulation({required bool reset}) async {
    if (_simulationRoute.isEmpty || _driverMarker == null) {
      return;
    }
    if (_isSimulationRunning && !reset) {
      return;
    }

    _simulationTimer?.cancel();
    if (reset) {
      _simulationIndex = 0;
    }

    if (mounted) {
      setState(() {
        _isSimulationRunning = true;
        _isSimulationCompleted = false;
      });
    }

    await _applySimulationFrame(followCamera: true);

    if (_simulationRoute.length <= 1) {
      _finishSimulation();
      return;
    }

    _simulationTimer = Timer.periodic(_simulationTick, (_) async {
      if (_simulationTickInFlight) {
        // Skip overlapping ticks when a previous frame update or camera
        // animation has not completed yet.
        return;
      }
      _simulationTickInFlight = true;
      try {
        if (!mounted) {
          _simulationTimer?.cancel();
          return;
        }

        if (_simulationIndex >= _simulationRoute.length - 1) {
          _finishSimulation();
          return;
        }

        _simulationIndex += 1;
        await _applySimulationFrame(followCamera: true);
        if (_simulationIndex >= _simulationRoute.length - 1) {
          _finishSimulation();
        }
      } finally {
        _simulationTickInFlight = false;
      }
    });
  }

  Future<void> _applySimulationFrame({required bool followCamera}) async {
    final map = _mapboxMap;
    final circles = _circleAnnotationManager;
    final driverMarker = _driverMarker;
    if (map == null || circles == null || driverMarker == null) {
      return;
    }

    final frame = frameForProgress(_simulationRoute, _simulationProgress);
    driverMarker.geometry = Point(coordinates: frame.position);
    await circles.update(driverMarker);

    if (!followCamera) {
      return;
    }
    // When following the route, update both position and bearing so the map
    // feels closer to turn-by-turn guidance.
    await map.easeTo(
      CameraOptions(
        center: Point(coordinates: frame.position),
        zoom: _followZoom,
        pitch: _followPitch,
        bearing: frame.bearing,
      ),
      MapAnimationOptions(duration: _simulationTick.inMilliseconds),
    );
  }

  Future<void> _replaySimulation() async {
    if (_simulationRoute.isEmpty) {
      return;
    }

    _cancelSimulationTimers();
    if (!mounted) {
      return;
    }

    setState(() {
      _simulationIndex = 0;
      _isSimulationRunning = false;
      _isSimulationCompleted = false;
    });

    await _applySimulationFrame(followCamera: false);
    await _fitRouteOverview();

    _simulationStartTimer = Timer(_overviewPause, () {
      if (!mounted) {
        return;
      }
      _startSimulation(reset: true);
    });
  }

  void _finishSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    if (!mounted) {
      return;
    }
    setState(() {
      _isSimulationRunning = false;
      _isSimulationCompleted = true;
    });
  }

  void _cancelSimulationTimers() {
    _simulationTimer?.cancel();
    _simulationStartTimer?.cancel();
    _simulationTimer = null;
    _simulationStartTimer = null;
    _simulationTickInFlight = false;
  }

  Future<List<Position>> _requestRouteWithFallback({
    required Position origin,
    required Position destination,
  }) async {
    // Try traffic-aware driving first, then degrade to plain driving if the
    // richer profile is unavailable for the current token or region.
    final profiles = ['mapbox/driving-traffic', 'mapbox/driving'];
    for (final profile in profiles) {
      try {
        final route = await _requestRoute(
          profile: profile,
          origin: origin,
          destination: destination,
        );
        if (route.isNotEmpty) {
          return route;
        }
      } catch (_) {
        // No-op: retry with next profile.
      }
    }
    throw const FormatException('No route geometry from fallback profiles');
  }

  Future<List<Position>> _requestRoute({
    required String profile,
    required Position origin,
    required Position destination,
  }) async {
    final routePath =
        '/directions/v5/$profile/${origin.lng},${origin.lat};${destination.lng},${destination.lat}';
    final uri = Uri.https('api.mapbox.com', routePath, {
      'alternatives': 'false',
      'geometries': 'geojson',
      'overview': 'full',
      'steps': 'false',
      'access_token': mapboxAccessToken,
    });

    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Directions request failed: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final code = payload['code'] as String?;
    if (code != null && code != 'Ok') {
      throw FormatException('Directions API code: $code');
    }
    final routes = payload['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) {
      throw const FormatException('No routes returned');
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'] as List<dynamic>? ?? const [];
    if (coordinates.isEmpty) {
      throw const FormatException('No route geometry');
    }

    return coordinates.map((coordinate) {
      final pair = coordinate as List<dynamic>;
      final lng = (pair[0] as num).toDouble();
      final lat = (pair[1] as num).toDouble();
      return Position(lng, lat);
    }).toList();
  }

  List<Position> _buildDirectRoute({
    required Position origin,
    required Position destination,
  }) {
    final samePoint =
        origin.lng == destination.lng && origin.lat == destination.lat;
    if (samePoint) {
      // Create a tiny offset so the renderer and simulator still have a visible
      // segment even when origin and destination collapse to the same point.
      return [
        origin,
        Position(
          origin.lng.toDouble() + 0.0005,
          origin.lat.toDouble() + 0.0005,
        ),
      ];
    }
    return [origin, destination];
  }

  bool get _canRenderMap => hasMapboxAccessToken && isMapboxPlatformSupported;

  String? get _missingCoordinatesMessage {
    const pickupUnavailable =
        'Precise pickup coordinates are unavailable. External navigation can still open.';
    const dropoffUnavailable =
        'Precise dropoff coordinates are unavailable. External navigation can still open.';

    return switch (widget.phase) {
      DriverRoutePhase.toPickup =>
        _pickupPosition == null ? pickupUnavailable : null,
      DriverRoutePhase.toDropoff => _pickupPosition == null
          ? pickupUnavailable
          : _dropoffPosition == null
              ? dropoffUnavailable
              : null,
    };
  }

  bool get _isMapReadyForRoute {
    // The screen waits for style, managers, and geometry before attempting any
    // annotation work.
    return _canRenderMap &&
        _styleLoaded &&
        _mapboxMap != null &&
        _circleAnnotationManager != null &&
        _polylineAnnotationManager != null &&
        _routeGeometry.isNotEmpty &&
        _simulationRoute.isNotEmpty;
  }

  Position get _initialCameraCenter {
    return switch (widget.phase) {
      DriverRoutePhase.toPickup => _routeOrigin,
      DriverRoutePhase.toDropoff => _pickupPosition!,
    };
  }

  Position get _routeOrigin {
    return switch (widget.phase) {
      DriverRoutePhase.toPickup => Position(
          (_driverStartPosition ?? _pickupPosition!).lng,
          (_driverStartPosition ?? _pickupPosition!).lat,
        ),
      DriverRoutePhase.toDropoff => _pickupPosition!,
    };
  }

  Position get _routeDestination {
    return switch (widget.phase) {
      DriverRoutePhase.toPickup => _pickupPosition!,
      DriverRoutePhase.toDropoff => _dropoffPosition!,
    };
  }

  Position? get _driverStartPosition {
    final lat = widget.job.driverStartLat;
    final lng = widget.job.driverStartLng;
    if (lat == null || lng == null) {
      return null;
    }

    return Position(lng, lat);
  }

  Position? get _pickupPosition {
    final lat = widget.job.pickupLat;
    final lng = widget.job.pickupLng;
    if (lat == null || lng == null) {
      return null;
    }

    return Position(lng, lat);
  }

  Position? get _dropoffPosition {
    final lat = widget.job.dropoffLat;
    final lng = widget.job.dropoffLng;
    if (lat == null || lng == null) {
      return null;
    }

    return Position(lng, lat);
  }

  String get _simulationStatusLabel {
    if (_isSimulationRunning) {
      return 'Simulation running';
    }
    if (_isSimulationCompleted) {
      return 'Simulation complete';
    }
    return 'Simulation ready';
  }

  double get _simulationProgress {
    if (_simulationRoute.length <= 1) {
      return 1;
    }
    final maxIndex = _simulationRoute.length - 1;
    return (_simulationIndex.clamp(0, maxIndex)) / maxIndex;
  }

  DriverNavigationDestination get _navigationDestination {
    // External navigation prefers coordinates but also includes the address so
    // fallback apps can still search by text if needed.
    return switch (widget.phase) {
      DriverRoutePhase.toPickup => DriverNavigationDestination(
          label: widget.job.pickup,
          lat: widget.job.pickupLat,
          lng: widget.job.pickupLng,
          query: widget.job.pickupAddressLine,
        ),
      DriverRoutePhase.toDropoff => DriverNavigationDestination(
          label: widget.job.dropoff,
          lat: widget.job.dropoffLat,
          lng: widget.job.dropoffLng,
          query: widget.job.dropoffAddressLine,
        ),
    };
  }

  Future<void> _openExternalNavigation() async {
    final launched = await widget.navigationService.navigateTo(
      _navigationDestination,
    );
    if (!mounted) {
      return;
    }
    if (launched) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('No navigation app is available for this destination.'),
        ),
      );
  }

  static String _phaseLabel(DriverRoutePhase phase) {
    return switch (phase) {
      DriverRoutePhase.toPickup => 'Heading to pickup',
      DriverRoutePhase.toDropoff => 'Heading to dropoff',
    };
  }

  static String _formatDestinationSubtitle(
    DriverNavigationDestination destination,
    String addressLine,
  ) {
    if (destination.lat == null || destination.lng == null) {
      return addressLine;
    }

    return '${destination.label} (${destination.lat!.toStringAsFixed(4)}, '
        '${destination.lng!.toStringAsFixed(4)})';
  }
}

class _MapUnavailableCard extends StatelessWidget {
  const _MapUnavailableCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          key: const Key('driver-map-unavailable'),
          // Keep this state visually lightweight because it is a fallback
          // screen, not a full replacement experience.
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message),
          ),
        ),
      ),
    );
  }
}
