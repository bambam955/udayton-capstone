import 'package:bizrush_shared/theme.dart';
import 'package:flutter/material.dart';

import 'ui/screens/home/driver_home_shell.dart';

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
