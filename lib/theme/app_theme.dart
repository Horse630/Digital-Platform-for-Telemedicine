import 'package:flutter/material.dart';

/// One accent the settings page can apply to the whole app.
class ThemeChoice {
  const ThemeChoice(this.name, this.color);

  final String name;
  final Color color;
}

/// Clinical theme shared by every screen.
class AppTheme {
  const AppTheme._();

  static const seed = Color(0xFF0F766E);

  static const choices = <ThemeChoice>[
    ThemeChoice('Teal', Color(0xFF0F766E)),
    ThemeChoice('Blue', Color(0xFF1D4ED8)),
    ThemeChoice('Green', Color(0xFF15803D)),
    ThemeChoice('Purple', Color(0xFF6D28D9)),
    ThemeChoice('Orange', Color(0xFFC2410C)),
  ];

  static ThemeData get light => themed(Brightness.light, seed);

  static ThemeData themed(Brightness brightness, Color seedColor) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    final scaffold = brightness == Brightness.dark
        ? scheme.surface
        : Color.alphaBlend(
            seedColor.withValues(alpha: 0.08),
            const Color(0xFFF7F7F7),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: border,
        enabledBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
