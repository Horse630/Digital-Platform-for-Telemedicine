import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:digital_platform_for_telemedicine/main.dart';
import 'package:digital_platform_for_telemedicine/services/auth_service.dart';

void main() {
  testWidgets('empty sign-in asks for both fields', (tester) async {
    await _pumpPhone(tester);

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('a wrong password stays on the login screen', (tester) async {
    await _pumpPhone(tester);

    await tester.enterText(find.byKey(const Key('usernameField')), 'doctor');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Username or password is incorrect.'), findsOneWidget);
    expect(find.text('Welcome back, Demo Doctor'), findsNothing);
  });

  testWidgets('Admin can open the dashboard, a tab, and log out', (
    tester,
  ) async {
    await _pumpPhone(tester);
    await _signIn(tester);

    expect(find.text('Welcome back, Demo Doctor'), findsOneWidget);
    expect(find.text('Doctor dashboard'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Appointments'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No time slots yet'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('an unavailable service tells the person to wait', (
    tester,
  ) async {
    await _pumpPhone(tester);
    await _signIn(tester);

    final sickLeave = find.text('Sick leave');
    await tester.ensureVisible(sickLeave);
    await tester.pumpAndSettle();
    await tester.tap(sickLeave);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This service is not available yet.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsNothing);
  });

  testWidgets('wide windows use the side rail', (tester) async {
    await _pumpSurface(tester, const Size(1200, 800));
    await _signIn(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}

Future<void> _pumpPhone(WidgetTester tester) {
  return _pumpSurface(tester, const Size(800, 600));
}

Future<void> _pumpSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(TelemedicineApp(authService: _testAuth()));
}

AuthService _testAuth() {
  return AuthService(
    baseUrl: 'http://localhost:3000',
    client: MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/api/appointments') {
        return http.Response('[]', 200);
      }
      if (request.method == 'GET' && request.url.path == '/api/profile') {
        return http.Response(
          jsonEncode({
            'username': 'doctor',
            'role': 'doctor',
            'fullName': 'Demo Doctor',
            'description': '',
            'avatarBase64': '',
            'avatarMime': '',
          }),
          200,
        );
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'doctor' && body['password'] == 'Doctor123!') {
        return http.Response(
          jsonEncode({
            'username': 'doctor',
            'role': 'doctor',
            'fullName': 'Demo Doctor',
            'token': 'test-token',
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({'message': 'Username or password is incorrect.'}),
        401,
      );
    }),
  );
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('usernameField')), 'doctor');
  await tester.enterText(find.byKey(const Key('passwordField')), 'Doctor123!');
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pumpAndSettle();
}
