import 'package:flutter/material.dart';

import 'ui/screens/home/driver_home_shell.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/no_stretch_scroll_behavior.dart';

void main() {
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
