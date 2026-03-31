import 'package:bizrush_shared/theme.dart';
import 'package:flutter/material.dart';

import 'config/customer_app_dependencies.dart';
import 'ui/screens/customer_app.dart';

/// Entry point for the customer Flutter app.
void main() {
  runApp(MyApp());
}

/// Root widget that wires production dependencies into the customer shell.
class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    CustomerAppDependencies? dependencies,
  }) : dependencies = dependencies ?? CustomerAppDependencies.production();

  final CustomerAppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizRush',
      theme: AppTheme.light(),
      scrollBehavior: const NoStretchScrollBehavior(),
      home: CustomerApp(dependencies: dependencies),
    );
  }
}
