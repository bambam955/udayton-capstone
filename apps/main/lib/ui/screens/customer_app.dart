import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';

import '../../config/customer_app_dependencies.dart';
import 'auth/customer_auth_screen.dart';
import 'home/customer_home_shell.dart';

/// Top-level customer app shell that decides between auth and home flows.
class CustomerApp extends StatefulWidget {
  const CustomerApp({
    super.key,
    required this.dependencies,
  });

  final CustomerAppDependencies dependencies;

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  ApiSession? _session;
  bool _isRestoring = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final restored = await widget.dependencies.authApi.restoreSession();
    if (restored == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRestoring = false;
      });
      return;
    }

    try {
      // Validate persisted sessions against the backend before trusting them.
      await widget.dependencies.authApi.me();
      if (!mounted) {
        return;
      }

      setState(() {
        _session = restored;
        _isRestoring = false;
      });
    } catch (_) {
      // A failed validation means the local session is no longer trustworthy,
      // so clear it and render the auth screen again.
      await widget.dependencies.authApi
          .logout(restored.user.role)
          .catchError((_) {});
      if (!mounted) {
        return;
      }

      setState(() {
        _session = null;
        _isRestoring = false;
      });
    }
  }

  void _handleAuthenticated(ApiSession session) {
    setState(() {
      _session = session;
    });
  }

  void _handleSignedOut() {
    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoring) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_session == null) {
      return CustomerAuthScreen(
        authApi: widget.dependencies.authApi,
        onAuthenticated: _handleAuthenticated,
      );
    }

    return CustomerHomeShell(
      session: _session!,
      authApi: widget.dependencies.authApi,
      customerApi: widget.dependencies.customerApi,
      resourceApi: widget.dependencies.resourceApi,
      onSignedOut: _handleSignedOut,
    );
  }
}
