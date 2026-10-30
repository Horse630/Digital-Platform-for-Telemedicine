import 'package:flutter/material.dart';

import '../language/language_settings.dart';
import '../language/ui_text.dart';
import '../theme/app_theme.dart';
import '../theme/theme_settings.dart';

/// Plays once when the process starts, then shows [next].
///
/// Widget tests build the sign-in app directly, so they do not wait for this.
class StartupHost extends StatefulWidget {
  const StartupHost({
    super.key,
    required this.themeSettings,
    required this.languageSettings,
    required this.next,
  });

  final ThemeSettings themeSettings;
  final LanguageSettings languageSettings;
  final Widget next;

  static const duration = Duration(milliseconds: 2200);

  @override
  State<StartupHost> createState() => _StartupHostState();
}

class _StartupHostState extends State<StartupHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: StartupHost.duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_finished) {
        setState(() => _finished = true);
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
    if (_finished) {
      return widget.next;
    }

    return LanguageScope(
      settings: widget.languageSettings,
      child: ThemeScope(
        settings: widget.themeSettings,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          locale: widget.languageSettings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.themed(Brightness.light, widget.themeSettings.seed),
          darkTheme: AppTheme.themed(Brightness.dark, widget.themeSettings.seed),
          themeMode: widget.themeSettings.mode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(widget.themeSettings.textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: _StartupSplash(animation: _controller),
        ),
      ),
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = animation.value;
            final leave = Interval(0.82, 1, curve: Curves.easeIn).transform(t);
            return Opacity(opacity: 1 - leave, child: child);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                key: const Key('startupAnimation'),
                width: 160,
                height: 160,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = animation.value;
                    final mark = Curves.easeOutBack.transform(
                      Interval(0, 0.42).transform(t),
                    );
                    final ring = Interval(0.08, 0.62).transform(t);
                    final camera = Curves.easeOutBack.transform(
                      Interval(0.28, 0.62).transform(t),
                    );
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: (1 - ring).clamp(0, 1),
                          child: Transform.scale(
                            scale: 0.72 + (ring * 0.55),
                            child: Container(
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: scheme.primary,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: mark,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const _MedicalMark(),
                          ),
                        ),
                        Transform.scale(
                          scale: camera,
                          child: Icon(
                            Icons.videocam_rounded,
                            size: 34,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final t = Interval(0.4, 0.72, curve: Curves.easeOut).transform(
                    animation.value,
                  );
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - t)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White cross drawn inside the teal circle, matching the launcher mark.
class _MedicalMark extends StatelessWidget {
  const _MedicalMark();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return Center(
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 16,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
