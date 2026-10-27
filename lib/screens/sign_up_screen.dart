import 'package:flutter/material.dart';

import '../language/ui_text.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                SegmentedButton<String>(
                  key: const Key('signUpRole'),
                  segments: [
                    ButtonSegment(value: 'patient', label: Text(l10n.patient)),
                    ButtonSegment(value: 'doctor', label: Text(l10n.doctor)),
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
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (!_emailPattern.hasMatch((value ?? '').trim())) {
                            return l10n.enterValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('signUpUsernameField'),
                        controller: _username,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: l10n.username,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (!_usernamePattern.hasMatch((value ?? '').trim())) {
                            return l10n.usernameRule;
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
                          labelText: l10n.password,
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
                            return l10n.atLeast8;
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
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value != _password.text) {
                            return l10n.samePasswordTwice;
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          localizeMessage(l10n, _errorMessage!),
                          key: const Key('signUpError'),
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('signUpButton'),
                        onPressed: _submit,
                        child: Text(_submitting ? l10n.creating : l10n.createAccountAction),
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
