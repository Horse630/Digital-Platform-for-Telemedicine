import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'main_shell.dart';

/// Creates a patient or doctor account with the same fields.
///
/// A later doctor sign-up step can ask for a specialty and license.
/// This screen does not collect those yet.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{3,40}$');
  static final _emailPattern = RegExp(r'^\S+@\S+\.\S+$');

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  String _role = 'patient';
  String? _errorMessage;
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = null);
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final user = await widget.authService.signUp(
        email: _email.text,
        username: _username.text,
        password: _password.text,
        role: _role,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => MainShell(user: user, authService: widget.authService),
        ),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                SegmentedButton<String>(
                  key: const Key('signUpRole'),
                  segments: const [
                    ButtonSegment(value: 'patient', label: Text('Patient')),
                    ButtonSegment(value: 'doctor', label: Text('Doctor')),
                  ],
                  selected: {_role},
                  onSelectionChanged: _submitting
                      ? null
                      : (selected) => setState(() => _role = selected.first),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        key: const Key('signUpEmailField'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (!_emailPattern.hasMatch((value ?? '').trim())) {
                            return 'Enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('signUpUsernameField'),
                        controller: _username,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (!_usernamePattern.hasMatch((value ?? '').trim())) {
                            return 'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('signUpPasswordField'),
                        controller: _password,
                        obscureText: _obscurePassword,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Use at least 8 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('signUpConfirmField'),
                        controller: _confirmPassword,
                        obscureText: _obscurePassword,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value != _password.text) {
                            return 'Enter the same password twice.';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          key: const Key('signUpError'),
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('signUpButton'),
                        onPressed: _submit,
                        child: Text(_submitting ? 'Creating...' : 'Create account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
