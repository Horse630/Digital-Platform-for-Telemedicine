import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TelemedicineApp());
}

class TelemedicineApp extends StatelessWidget {
  const TelemedicineApp({super.key, this.authService = const AuthService()});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Platform for Telemedicine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: LoginScreen(authService: authService),
    );
  }
}
