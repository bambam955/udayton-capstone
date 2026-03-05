import 'package:flutter/material.dart';

import 'ui/screens/home/customer_home_shell.dart';
import 'ui/theme/no_stretch_scroll_behavior.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizRush',
      theme: AppTheme.light(),
      scrollBehavior: const NoStretchScrollBehavior(),
      home: const CustomerHomeShell(),
    );
  }
}
