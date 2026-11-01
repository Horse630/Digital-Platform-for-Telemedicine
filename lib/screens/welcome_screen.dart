import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

/// Short greeting shown after a successful sign-in or sign-up.
///
/// It uses the account username, then opens the signed-in shell.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  final SignedInUser user;
  final AuthService authService;

  static const duration = Duration(milliseconds: 1600);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: WelcomeScreen.duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_opened) {
        _opened = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => MainShell(
              user: widget.user,
              authService: widget.authService,
            ),
          ),
        );
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final enter = Curves.easeOutBack.transform(
              Interval(0, 0.55).transform(t),
            );
            final leave = Interval(0.78, 1, curve: Curves.easeIn).transform(t);
            return Opacity(
              opacity: (1 - leave).clamp(0, 1),
              child: Transform.scale(scale: enter, child: child),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              key: const Key('welcomeAnimation'),
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Icon(
                      Icons.waving_hand_outlined,
                      size: 36,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.welcomeUser(widget.user.username),
                  key: const Key('welcomeUsername'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
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
