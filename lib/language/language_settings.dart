import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language the client shows. It stays on this device.
///
/// The default is English even when the phone language is Chinese, so the
/// app does not change until the person picks a language in Settings.
class LanguageSettings extends ChangeNotifier {
  LanguageSettings([Locale? locale]) : _locale = locale ?? const Locale('en');

  static const storageKey = 'ui_language';

  Locale _locale;

  Locale get locale => _locale;

  static Future<LanguageSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LanguageSettings(localeFromCode(prefs.getString(storageKey)));
  }

  Future<void> setLocale(Locale locale) async {
    if (_same(locale, _locale)) {
      return;
    }
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, codeFor(locale));
  }

  static Locale localeFromCode(String? code) {
    switch (code) {
      case 'zh_Hant':
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      case 'zh_Hans':
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      default:
        return const Locale('en');
    }
  }

  static String codeFor(Locale locale) {
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return 'zh_Hant';
    }
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hans') {
      return 'zh_Hans';
    }
    return 'en';
  }

  static bool _same(Locale a, Locale b) {
    return a.languageCode == b.languageCode && a.scriptCode == b.scriptCode;
  }
}

class LanguageScope extends InheritedNotifier<LanguageSettings> {
  const LanguageScope({
    super.key,
    required LanguageSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static LanguageSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(scope != null, 'LanguageScope is missing above this widget');
    return scope!.notifier!;
  }
}
