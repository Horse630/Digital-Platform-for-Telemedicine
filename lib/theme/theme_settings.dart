import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// Light or dark mode and the accent color chosen on the settings page.
///
/// These values stay on this device. MongoDB does not store them.
class ThemeSettings extends ChangeNotifier {
  ThemeSettings({this._mode = ThemeMode.light, Color seed = AppTheme.seed})
    : _seed = seed;

  static const modeKey = 'ui_theme_mode';
  static const seedKey = 'ui_theme_seed';

  ThemeMode _mode;
  Color _seed;

  ThemeMode get mode => _mode;
  Color get seed => _seed;
  bool get isDark => _mode == ThemeMode.dark;

  static Future<ThemeSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(modeKey) == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    final seed = _colorFromHex(prefs.getString(seedKey)) ?? AppTheme.seed;
    return ThemeSettings(mode: mode, seed: seed);
  }

  Future<void> setDark(bool dark) {
    return _update(mode: dark ? ThemeMode.dark : ThemeMode.light, seed: _seed);
  }

  Future<void> setSeed(Color seed) {
    if (!AppTheme.choices.any(
      (choice) => choice.color.toARGB32() == seed.toARGB32(),
    )) {
      return Future<void>.value();
    }
    return _update(mode: _mode, seed: seed);
  }

  Future<void> _update({required ThemeMode mode, required Color seed}) async {
    if (_mode == mode && _seed.toARGB32() == seed.toARGB32()) {
      return;
    }
    _mode = mode;
    _seed = seed;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(modeKey, mode == ThemeMode.dark ? 'dark' : 'light');
      await prefs.setString(
        seedKey,
        seed.toARGB32().toRadixString(16).padLeft(8, '0'),
      );
    } catch (_error) {
      // The choice still applies until the app is closed.
    }
  }
}

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) {
    return null;
  }
  final value = int.tryParse(hex, radix: 16);
  if (value == null) {
    return null;
  }
  final color = Color(value);
  final known = AppTheme.choices.any(
    (choice) => choice.color.toARGB32() == color.toARGB32(),
  );
  return known ? color : null;
}

/// Exposes [ThemeSettings] to the settings page.
class ThemeScope extends InheritedNotifier<ThemeSettings> {
  const ThemeScope({
    super.key,
    required ThemeSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static ThemeSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope is missing above this widget');
    return scope!.notifier!;
  }
}
