import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeSettings = await _loadTheme();
  runApp(TelemedicineApp(themeSettings: themeSettings));
}

Future<ThemeSettings> _loadTheme() async {
  try {
    return await ThemeSettings.load();
  } catch (_error) {
    return ThemeSettings();
  }
}

class TelemedicineApp extends StatefulWidget {
  const TelemedicineApp({
    super.key,
    this.authService = const AuthService(),
    this.themeSettings,
  });

  final AuthService authService;
  final ThemeSettings? themeSettings;

  @override
  State<TelemedicineApp> createState() => _TelemedicineAppState();
}

class _TelemedicineAppState extends State<TelemedicineApp> {
  late final ThemeSettings _settings = widget.themeSettings ?? ThemeSettings();
  late final bool _ownsSettings = widget.themeSettings == null;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onTheme);
  }

  @override
  void dispose() {
    _settings.removeListener(_onTheme);
    if (_ownsSettings) {
      _settings.dispose();
    }
    super.dispose();
  }

  void _onTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      settings: _settings,
      child: MaterialApp(
        title: 'Digital Platform for Telemedicine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themed(Brightness.light, _settings.seed),
        darkTheme: AppTheme.themed(Brightness.dark, _settings.seed),
        themeMode: _settings.mode,
        home: LoginScreen(authService: widget.authService),
      ),
    );
  }
}
