import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';
import 'sign_up_screen.dart';

/// Sign-in screen.
///
/// [AuthService] sends the username and password to the Node API, which
/// checks them in MongoDB. A match opens the signed-in shell.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authService = const AuthService()});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }
    setState(() => _errorMessage = null);
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final user = await widget.authService.signIn(
        _username.text,
        _password.text,
      );
      if (!mounted) {
        return;
      }
      // Replace the login route so the system back button leaves the app.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              MainShell(user: user, authService: widget.authService),
        ),
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

  void _openSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignUpScreen(authService: widget.authService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final errorMessage = _errorMessage;
    final l10n = context.l10n;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.7),
              const Color(0xFFF4F7F7),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = (constraints.maxHeight - 48).clamp(
                0.0,
                double.infinity,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Material(
                        color: scheme.surface,
                        elevation: 1,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autovalidateMode,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _LoginMark(),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.appTitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.appTagline,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  key: const Key('usernameField'),
                                  controller: _username,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.username],
                                  decoration: InputDecoration(
                                    labelText: l10n.username,
                                    prefixIcon: const Icon(Icons.person_outline),
                                  ),
                                  onChanged: (_) => _clearError(),
                                  onFieldSubmitted: (_) {
                                    _passwordFocus.requestFocus();
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.enterUsername;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  key: const Key('passwordField'),
                                  controller: _password,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    labelText: l10n.password,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? l10n.showPassword
                                          : l10n.hidePassword,
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  onChanged: (_) => _clearError(),
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.enterPassword;
                                    }
                                    return null;
                                  },
                                ),
                                if (errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Material(
                                    color: scheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: scheme.onErrorContainer,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              localizeMessage(l10n, errorMessage),
                                              key: const Key('loginError'),
                                              style: TextStyle(
                                                color: scheme.onErrorContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                FilledButton(
                                  key: const Key('loginButton'),
                                  onPressed: _submitting ? null : _submit,
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(l10n.signIn),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  key: const Key('createAccountButton'),
                                  onPressed: _submitting ? null : _openSignUp,
                                  child: Text(l10n.createAccount),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginMark extends StatelessWidget {
  const _LoginMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            Icons.medical_services_outlined,
            size: 36,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
