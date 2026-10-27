import 'package:flutter/material.dart';

import 'language/app_localizations.dart';
import 'language/language_settings.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeSettings = await _loadTheme();
  final languageSettings = await _loadLanguage();
  runApp(
    TelemedicineApp(
      themeSettings: themeSettings,
      languageSettings: languageSettings,
    ),
  );
}

Future<ThemeSettings> _loadTheme() async {
  try {
    return await ThemeSettings.load();
  } catch (_) {
    return ThemeSettings();
  }
}

Future<LanguageSettings> _loadLanguage() async {
  try {
    return await LanguageSettings.load();
  } catch (_) {
    return LanguageSettings();
  }
}

class TelemedicineApp extends StatefulWidget {
  const TelemedicineApp({
    super.key,
    this.authService = const AuthService(),
    this.themeSettings,
    this.languageSettings,
  });

  final AuthService authService;
  final ThemeSettings? themeSettings;
  final LanguageSettings? languageSettings;

  @override
  State<TelemedicineApp> createState() => _TelemedicineAppState();
}

class _TelemedicineAppState extends State<TelemedicineApp> {
  late final ThemeSettings _settings = widget.themeSettings ?? ThemeSettings();
  late final bool _ownsSettings = widget.themeSettings == null;
  late final LanguageSettings _language =
      widget.languageSettings ?? LanguageSettings();
  late final bool _ownsLanguage = widget.languageSettings == null;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onTheme);
    _language.addListener(_onTheme);
  }

  @override
  void dispose() {
    _settings.removeListener(_onTheme);
    _language.removeListener(_onTheme);
    if (_ownsSettings) {
      _settings.dispose();
    }
    if (_ownsLanguage) {
      _language.dispose();
    }
    super.dispose();
  }

  void _onTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      settings: _language,
      child: ThemeScope(
        settings: _settings,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          locale: _language.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.themed(Brightness.light, _settings.seed),
          darkTheme: AppTheme.themed(Brightness.dark, _settings.seed),
          themeMode: _settings.mode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(_settings.textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: LoginScreen(authService: widget.authService),
        ),
      ),
    );
  }
}
