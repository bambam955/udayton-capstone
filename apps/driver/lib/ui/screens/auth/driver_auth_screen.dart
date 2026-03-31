import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';

import '../../widgets/surface_card.dart';

/// Minimal authentication screen for drivers.
class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({
    super.key,
    required this.authApi,
    required this.onAuthenticated,
  });

  final AuthApi authApi;
  final ValueChanged<ApiSession> onAuthenticated;

  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // The shared auth API accepts a role discriminator so the backend can
      // apply driver-specific login rules behind the same endpoint family.
      final session = await widget.authApi.login(
        role: ApiUserRole.driver,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        deviceInfo: 'driver-app',
      );
      if (!mounted) {
        return;
      }

      widget.onAuthenticated(session);
    } on ApiError catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('BizRush Driver', style: textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage live offers, deliveries, support, and earnings.',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    SurfaceCard(
                      child: Column(
                        children: [
                          // Tests target these fields directly, so keep the
                          // keys stable even as the surrounding layout evolves.
                          TextFormField(
                            key: const Key('driver-auth-email'),
                            controller: _emailController,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty || !email.contains('@')) {
                                return 'Enter a valid email.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('driver-auth-password'),
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a password.';
                              }

                              return null;
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              key: const Key('driver-auth-error'),
                              style: textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const Key('driver-auth-submit'),
                              onPressed: _isSubmitting ? null : _submit,
                              child: Text(
                                  _isSubmitting ? 'Please wait...' : 'Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
