import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// Light or dark mode and the accent color chosen on the settings page.
///
/// These values stay on this device. MongoDB does not store them.
class ThemeSettings extends ChangeNotifier {
  ThemeSettings({
    this._mode = ThemeMode.light,
    this._seed = AppTheme.seed,
    String fontSize = normalFont,
  }) : _fontSize = fontSizes.containsKey(fontSize) ? fontSize : normalFont;

  static const modeKey = 'ui_theme_mode';
  static const seedKey = 'ui_theme_seed';
  static const fontKey = 'ui_font_size';
  static const normalFont = 'normal';

  /// Named sizes used by Settings. The value is the text scale for every page.
  static const fontSizes = <String, double>{
    'small': 0.9,
    normalFont: 1,
    'large': 1.2,
    'extra': 1.4,
  };

  ThemeMode _mode;
  Color _seed;
  String _fontSize;

  ThemeMode get mode => _mode;
  Color get seed => _seed;
  bool get isDark => _mode == ThemeMode.dark;
  String get fontSize => _fontSize;
  double get textScale => fontSizes[_fontSize] ?? 1;

  static Future<ThemeSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(modeKey) == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    final seed = _colorFromHex(prefs.getString(seedKey)) ?? AppTheme.seed;
    final savedFont = prefs.getString(fontKey);
    final fontSize = fontSizes.containsKey(savedFont) ? savedFont! : normalFont;
    return ThemeSettings(mode: mode, seed: seed, fontSize: fontSize);
  }

  Future<void> setDark(bool dark) {
    return _update(
      mode: dark ? ThemeMode.dark : ThemeMode.light,
      seed: _seed,
      fontSize: _fontSize,
    );
  }

  Future<void> setSeed(Color seed) {
    if (!AppTheme.choices.any(
      (choice) => choice.color.toARGB32() == seed.toARGB32(),
    )) {
      return Future<void>.value();
    }
    return _update(mode: _mode, seed: seed, fontSize: _fontSize);
  }

  Future<void> setFontSize(String fontSize) {
    if (!fontSizes.containsKey(fontSize)) {
      return Future<void>.value();
    }
    return _update(mode: _mode, seed: _seed, fontSize: fontSize);
  }

  Future<void> _update({
    required ThemeMode mode,
    required Color seed,
    required String fontSize,
  }) async {
    if (_mode == mode &&
        _seed.toARGB32() == seed.toARGB32() &&
        _fontSize == fontSize) {
      return;
    }
    _mode = mode;
    _seed = seed;
    _fontSize = fontSize;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(modeKey, mode == ThemeMode.dark ? 'dark' : 'light');
      await prefs.setString(
        seedKey,
        seed.toARGB32().toRadixString(16).padLeft(8, '0'),
      );
      await prefs.setString(fontKey, fontSize);
    } catch (_) {
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
