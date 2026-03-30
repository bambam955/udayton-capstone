import 'package:bizrush_shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'config/driver_app_dependencies.dart';
import 'config/mapbox_config.dart';
import 'ui/screens/driver_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  if (isMapboxPlatformSupported && hasMapboxAccessToken) {
    MapboxOptions.setAccessToken(mapboxAccessToken);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    DriverAppDependencies? dependencies,
  }) : dependencies = dependencies ?? DriverAppDependencies.production();

  final DriverAppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizRush Driver',
      theme: AppTheme.light(),
      scrollBehavior: const NoStretchScrollBehavior(),
      home: DriverApp(dependencies: dependencies),
    );
  }
}
