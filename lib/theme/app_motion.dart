import 'package:flutter/material.dart';

/// Shared motion for every pushed page and every tab change.
class AppMotion {
  const AppMotion._();

  static const duration = Duration(milliseconds: 280);
  static const curve = Curves.easeOutCubic;
  static const reverseCurve = Curves.easeInCubic;
  static const enterOffset = Offset(0.04, 0);

  static const pageTransitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: AppPageTransitionsBuilder(),
      TargetPlatform.iOS: AppPageTransitionsBuilder(),
      TargetPlatform.linux: AppPageTransitionsBuilder(),
      TargetPlatform.macOS: AppPageTransitionsBuilder(),
      TargetPlatform.windows: AppPageTransitionsBuilder(),
      TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
    },
  );
}

/// Fade plus a short slide. Used by every [MaterialPageRoute].
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.duration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.curve,
      reverseCurve: AppMotion.reverseCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: AppMotion.enterOffset,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
