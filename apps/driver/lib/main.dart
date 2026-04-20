import 'package:bizrush_shared/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'config/driver_app_dependencies.dart';
import 'config/mapbox_config.dart';
import 'ui/screens/driver_app.dart';
import 'ui/screens/home/driver_home_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The local env asset is optional so CI and test runs do not depend on an
  // ignored secrets file being present in the checkout.
  await dotenv.load(fileName: 'assets/env/local.env', isOptional: true);
  // Mapbox should be configured only when the current platform can actually
  // host the native view and a token is present.
  if (isMapboxPlatformSupported && hasMapboxAccessToken) {
    MapboxOptions.setAccessToken(mapboxAccessToken);
  }
  runApp(MyApp());
}

/// Root widget that wires production dependencies into the driver shell.
class MyApp extends StatefulWidget {
  MyApp({
    super.key,
    DriverAppDependencies? dependencies,
  }) : dependencies = dependencies ?? DriverAppDependencies.production();

  final DriverAppDependencies dependencies;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _DriverRouterDelegate _routerDelegate =
      _DriverRouterDelegate(dependencies: widget.dependencies);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BizRush Driver',
      theme: AppTheme.light(),
      scrollBehavior: const NoStretchScrollBehavior(),
      routeInformationParser: const _DriverRouteInformationParser(),
      routerDelegate: _routerDelegate,
    );
  }
}

class _DriverRouteInformationParser extends RouteInformationParser<String> {
  const _DriverRouteInformationParser();

  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    return SynchronousFuture<String>(
      driverNormalizeRoutePath(routeInformation.uri.path),
    );
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(
      uri: Uri(path: driverNormalizeRoutePath(configuration)),
    );
  }
}

class _DriverRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  _DriverRouterDelegate({required this.dependencies});

  final DriverAppDependencies dependencies;
  String _routePath = driverDefaultRoutePath;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String get currentConfiguration => _routePath;

  void _handleRouteChanged(String routePath) {
    final nextRoutePath = driverNormalizeRoutePath(routePath);
    if (_routePath == nextRoutePath) {
      return;
    }

    _routePath = nextRoutePath;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _routePath = driverNormalizeRoutePath(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[
        // Use a stable page key so browser route changes preserve the restored
        // session and all tab-local state inside DriverApp.
        MaterialPage<void>(
          key: const ValueKey<String>('driver-app-shell'),
          name: _routePath,
          child: DriverApp(
            dependencies: dependencies,
            initialRoutePath: _routePath,
            onRouteChanged: _handleRouteChanged,
          ),
        ),
      ],
      onDidRemovePage: (page) {},
    );
  }
}
