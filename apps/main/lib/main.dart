import 'package:bizrush_shared/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/customer_app_dependencies.dart';
import 'ui/screens/customer_app.dart';
import 'ui/screens/home/customer_home_models.dart';

/// Entry point for the customer Flutter app.
void main() {
  runApp(MyApp());
}

/// Root widget that wires production dependencies into the customer shell.
class MyApp extends StatefulWidget {
  MyApp({
    super.key,
    CustomerAppDependencies? dependencies,
  }) : dependencies = dependencies ?? CustomerAppDependencies.production();

  final CustomerAppDependencies dependencies;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _CustomerRouterDelegate _routerDelegate =
      _CustomerRouterDelegate(dependencies: widget.dependencies);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BizRush',
      theme: AppTheme.light(),
      scrollBehavior: const NoStretchScrollBehavior(),
      routeInformationParser: const _CustomerRouteInformationParser(),
      routerDelegate: _routerDelegate,
    );
  }
}

class _CustomerRouteInformationParser extends RouteInformationParser<String> {
  const _CustomerRouteInformationParser();

  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    return SynchronousFuture<String>(
      customerNormalizeRoutePath(routeInformation.uri.path),
    );
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(
      uri: Uri(path: customerNormalizeRoutePath(configuration)),
    );
  }
}

class _CustomerRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  _CustomerRouterDelegate({required this.dependencies});

  final CustomerAppDependencies dependencies;
  String _routePath = customerDefaultRoutePath;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String get currentConfiguration => _routePath;

  void _handleRouteChanged(String routePath) {
    final nextRoutePath = customerNormalizeRoutePath(routePath);
    if (_routePath == nextRoutePath) {
      return;
    }

    _routePath = nextRoutePath;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _routePath = customerNormalizeRoutePath(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[
        // Use a stable page key so browser route changes preserve the restored
        // session and all tab-local state inside CustomerApp.
        MaterialPage<void>(
          key: const ValueKey<String>('customer-app-shell'),
          name: _routePath,
          child: CustomerApp(
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
