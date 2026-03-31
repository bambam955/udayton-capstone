import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';

import '../../config/driver_app_dependencies.dart';
import 'auth/driver_auth_screen.dart';
import 'home/driver_home_shell.dart';

/// Top-level driver app shell that decides between auth and home flows.
class DriverApp extends StatefulWidget {
  const DriverApp({
    super.key,
    required this.dependencies,
  });

  final DriverAppDependencies dependencies;

  @override
  State<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> {
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
      // Validate the persisted session with the backend before rendering the
      // authenticated experience. This keeps expired or revoked sessions from
      // silently booting into a broken home screen.
      await widget.dependencies.authApi.me();
      if (!mounted) {
        return;
      }

      setState(() {
        _session = restored;
        _isRestoring = false;
      });
    } catch (_) {
      // Best-effort logout clears local secure storage even if the server can
      // no longer recognize the session.
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
      return DriverAuthScreen(
        authApi: widget.dependencies.authApi,
        onAuthenticated: _handleAuthenticated,
      );
    }

    return DriverHomeShell(
      session: _session!,
      authApi: widget.dependencies.authApi,
      driverApi: widget.dependencies.driverApi,
      resourceApi: widget.dependencies.resourceApi,
      onSignedOut: _handleSignedOut,
    );
  }
}
