import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:digital_platform_for_telemedicine/theme/app_theme.dart';
import 'package:digital_platform_for_telemedicine/theme/theme_settings.dart';

void main() {
  test('saves dark mode and the chosen color on this device', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = ThemeSettings();

    await settings.setDark(true);
    await settings.setSeed(AppTheme.choices[1].color);
    await settings.setFontSize('large');
    final loaded = await ThemeSettings.load();

    expect(loaded.isDark, isTrue);
    expect(loaded.seed.toARGB32(), AppTheme.choices[1].color.toARGB32());
    expect(loaded.fontSize, 'large');
    expect(loaded.textScale, 1.2);
  });
}
