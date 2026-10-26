import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:digital_platform_for_telemedicine/main.dart';
import 'package:digital_platform_for_telemedicine/services/auth_service.dart';

void main() {
  testWidgets('sign up blocks a taken username and opens the home screen', (
    tester,
  ) async {
    late Map<String, dynamic> sent;

    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TelemedicineApp(
        authService: AuthService(
          baseUrl: 'http://localhost:3000',
          client: MockClient((request) async {
            if (request.method == 'GET') {
              if (request.url.path == '/api/appointments') {
                return http.Response('[]', 200);
              }
              return http.Response(
                jsonEncode({
                  'username': 'newdoc',
                  'role': 'doctor',
                  'fullName': 'newdoc',
                  'description': '',
                  'avatarBase64': '',
                  'avatarMime': '',
                }),
                200,
              );
            }
            sent = jsonDecode(request.body) as Map<String, dynamic>;
            if (request.url.path == '/api/signup' && sent['username'] == 'doctor') {
              return http.Response(
                jsonEncode({'message': 'That username is already used.'}),
                409,
              );
            }
            if (request.url.path == '/api/signup') {
              return http.Response(
                jsonEncode({
                  'username': sent['username'],
                  'role': sent['role'],
                  'fullName': sent['username'],
                  'token': 'new-token',
                }),
                201,
              );
            }
            return http.Response('{}', 404);
          }),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('createAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('signUpButton')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('signUpEmailField')),
      'new@telemedicine.local',
    );
    await tester.enterText(find.byKey(const Key('signUpUsernameField')), 'doctor');
    await tester.enterText(find.byKey(const Key('signUpPasswordField')), 'NewPass123');
    await tester.enterText(find.byKey(const Key('signUpConfirmField')), 'NewPass123');
    await tester.tap(find.byKey(const Key('signUpButton')));
    await tester.pumpAndSettle();
    expect(find.text('That username is already used.'), findsOneWidget);

    await tester.tap(find.text('Doctor'));
    await tester.enterText(find.byKey(const Key('signUpUsernameField')), 'newdoc');
    await tester.ensureVisible(find.byKey(const Key('signUpButton')));
    await tester.tap(find.byKey(const Key('signUpButton')));
    await tester.pumpAndSettle();

    expect(sent['role'], 'doctor');
    expect(sent['email'], 'new@telemedicine.local');
    expect(find.text('Welcome back, newdoc'), findsOneWidget);
    expect(find.text('Doctor dashboard'), findsOneWidget);
  });
}
