import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';

import '../../widgets/surface_card.dart';

/// Driver auth can either log in an existing account or create a new one.
enum _AuthMode { login, signup }

/// Authentication screen for drivers.
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
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;
  _AuthMode _mode = _AuthMode.login;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
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
      // Driver auth shares one screen, so only the requested API call changes
      // between the login and signup modes.
      final session = switch (_mode) {
        _AuthMode.login => await widget.authApi.login(
            role: ApiUserRole.driver,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            deviceInfo: 'driver-app',
          ),
        _AuthMode.signup => await widget.authApi.signup(
            role: ApiUserRole.driver,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            deviceInfo: 'driver-app',
          ),
      };
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                // Preserve the centered login layout on roomy screens while
                // still allowing signup content to scroll on shorter ones.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('BizRush Driver', style: textTheme.displaySmall),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in or create an account to manage live offers, deliveries, support, and earnings.',
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Keeping both auth modes in one place makes it
                                // easier to test and lets onboarding start from the
                                // same entry screen as login.
                                SegmentedButton<_AuthMode>(
                                  segments: const <ButtonSegment<_AuthMode>>[
                                    ButtonSegment<_AuthMode>(
                                      value: _AuthMode.login,
                                      label: Text('Login'),
                                    ),
                                    ButtonSegment<_AuthMode>(
                                      value: _AuthMode.signup,
                                      label: Text('Sign up'),
                                    ),
                                  ],
                                  selected: <_AuthMode>{_mode},
                                  onSelectionChanged: (selection) {
                                    setState(() {
                                      _mode = selection.first;
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (_mode == _AuthMode.signup) ...[
                                  TextFormField(
                                    key: const Key('driver-auth-full-name'),
                                    controller: _fullNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full name',
                                    ),
                                    validator: (value) {
                                      if (_mode == _AuthMode.signup &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return 'Enter your full name.';
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    key: const Key('driver-auth-phone'),
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 12),
                                ],
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
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                  ),
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
                                      color:
                                          Theme.of(context).colorScheme.error,
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
                                      _isSubmitting
                                          ? 'Please wait...'
                                          : (_mode == _AuthMode.login
                                              ? 'Login'
                                              : 'Create account'),
                                    ),
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
            );
          },
        ),
      ),
    );
  }
}
