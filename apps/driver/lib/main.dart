import 'package:bizrush_shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'config/mapbox_config.dart';
import 'ui/screens/home/driver_home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  if (isMapboxPlatformSupported && hasMapboxAccessToken) {
    MapboxOptions.setAccessToken(mapboxAccessToken);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizRush Driver',
      theme: AppTheme.light(),
      scrollBehavior: const NoStretchScrollBehavior(),
      home: const DriverHomeShell(),
    );
  }
}
