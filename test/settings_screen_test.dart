import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:digital_platform_for_telemedicine/main.dart';
import 'package:digital_platform_for_telemedicine/services/auth_service.dart';

void main() {
  testWidgets('settings saves a description and can switch to dark mode', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var description = 'Clinic notes';
    String? savedUsername;
    List<dynamic>? savedTypes;

    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TelemedicineApp(
        authService: AuthService(
          baseUrl: 'http://localhost:3000',
          client: MockClient((request) async {
            if (request.method == 'GET' &&
                request.url.path == '/api/appointments') {
              return http.Response('[]', 200);
            }
            if (request.method == 'GET' && (request.url.path == '/api/messages' ||
                    request.url.path == '/api/discussions')) {
              return http.Response('[]', 200);
            }
            if (request.method == 'GET' && request.url.path == '/api/profile') {
              return http.Response(_profile(description), 200);
            }
            if (request.method == 'PATCH' &&
                request.url.path == '/api/profile') {
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              description = body['description'] as String;
              savedUsername = body['username'] as String;
              savedTypes = body['specialties'] as List<dynamic>?;
              return http.Response(
                _profile(description, token: 'next-token'),
                200,
              );
            }
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            if (body['username'] == 'doctor' &&
                body['password'] == 'Doctor123!') {
              return http.Response(_login(), 200);
            }
            return http.Response(
              jsonEncode({'message': 'Username or password is incorrect.'}),
              401,
            );
          }),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('usernameField')), 'doctor');
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'Doctor123!',
    );
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Clinic notes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Upload photo'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('doctorType_Dermatology')));
    await tester.tap(find.byKey(const Key('doctorType_Dermatology')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('settingsDescriptionField')),
      'On duty this week',
    );
    await tester.ensureVisible(find.byKey(const Key('saveProfileButton')));
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();

    expect(savedUsername, 'doctor');
    expect(savedTypes, contains('Dermatology'));
    expect(find.text('Profile saved.'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('darkModeSwitch')));
    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const Key('darkModeSwitch')));
    expect(Theme.of(context).brightness, Brightness.dark);

    final before = Theme.of(
      tester.element(find.byKey(const Key('themeColorBlue'))),
    ).colorScheme.primary;
    await tester.tap(find.byKey(const Key('themeColorBlue')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byKey(const Key('themeColorBlue'))))
          .colorScheme
          .primary,
      isNot(before),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('On duty this week'), findsOneWidget);
  });

  testWidgets('a mismatched new password stays on the settings page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TelemedicineApp(authService: _auth()));
    await tester.enterText(find.byKey(const Key('usernameField')), 'doctor');
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'Doctor123!',
    );
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('currentPasswordField')));
    await tester.enterText(
      find.byKey(const Key('currentPasswordField')),
      'Doctor123!',
    );
    await tester.enterText(
      find.byKey(const Key('newPasswordField')),
      'NewPass123',
    );
    await tester.enterText(
      find.byKey(const Key('confirmPasswordField')),
      'Different1',
    );
    await tester.ensureVisible(find.byKey(const Key('changePasswordButton')));
    await tester.tap(find.byKey(const Key('changePasswordButton')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the same password twice.'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('a patient can add an allergy tag', (tester) async {
    SharedPreferences.setMockInitialValues({});
    List<dynamic>? savedAllergies;
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TelemedicineApp(
        authService: AuthService(
          baseUrl: 'http://localhost:3000',
          client: MockClient((request) async {
            if (request.method == 'GET' &&
                request.url.path == '/api/appointments') {
              return http.Response('[]', 200);
            }
            if (request.method == 'GET' && (request.url.path == '/api/messages' ||
                    request.url.path == '/api/discussions')) {
              return http.Response('[]', 200);
            }
            if (request.method == 'GET' && request.url.path == '/api/profile') {
              return http.Response(_patientProfile(), 200);
            }
            if (request.method == 'PATCH' &&
                request.url.path == '/api/profile') {
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              savedAllergies = body['allergies'] as List<dynamic>?;
              return http.Response(
                _patientProfile(allergies: savedAllergies),
                200,
              );
            }
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            if (body['username'] == 'patient' &&
                body['password'] == 'Patient123!') {
              return http.Response(_patientLogin(), 200);
            }
            return http.Response('{}', 401);
          }),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('usernameField')), 'patient');
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'Patient123!',
    );
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('allergyField')));
    await tester.enterText(find.byKey(const Key('allergyField')), 'Peanuts');
    await tester.tap(find.byKey(const Key('addAllergyButton')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('saveProfileButton')));
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();

    expect(savedAllergies, ['Peanuts']);
    expect(find.text('Peanuts'), findsWidgets);
  });
}

String _patientLogin() {
  return jsonEncode({
    'username': 'patient',
    'role': 'patient',
    'fullName': 'Demo Patient',
    'token': 'patient-token',
  });
}

String _patientProfile({List<dynamic>? allergies}) {
  return jsonEncode({
    'username': 'patient',
    'role': 'patient',
    'fullName': 'Demo Patient',
    'description': '',
    'avatarBase64': '',
    'avatarMime': '',
    'specialties': <String>[],
    'allergies': allergies ?? <String>[],
  });
}

String _login() {
  return jsonEncode({
    'username': 'doctor',
    'role': 'doctor',
    'fullName': 'Demo Doctor',
    'token': 'test-token',
  });
}

String _profile(String description, {String? token}) {
  return jsonEncode({
    'username': 'doctor',
    'role': 'doctor',
    'fullName': 'Demo Doctor',
    'description': description,
    'avatarBase64': '',
    'avatarMime': '',
    'token': ?token,
  });
}

AuthService _auth() {
  return AuthService(
    baseUrl: 'http://localhost:3000',
    client: MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/api/appointments') {
        return http.Response('[]', 200);
      }
      if (request.method == 'GET' && (request.url.path == '/api/messages' ||
                    request.url.path == '/api/discussions')) {
        return http.Response('[]', 200);
      }
      if (request.method == 'GET' && request.url.path == '/api/profile') {
        return http.Response(_profile(''), 200);
      }
      if (request.method == 'POST' &&
          request.url.path == '/api/profile/password') {
        return http.Response(jsonEncode({'message': 'Password updated.'}), 200);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'doctor' && body['password'] == 'Doctor123!') {
        return http.Response(_login(), 200);
      }
      return http.Response(
        jsonEncode({'message': 'Username or password is incorrect.'}),
        401,
      );
    }),
  );
}
