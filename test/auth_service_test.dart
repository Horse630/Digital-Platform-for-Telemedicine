import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:digital_platform_for_telemedicine/services/auth_service.dart';

void main() {
  test('posts the trimmed username and returns the database user', () async {
    late Map<String, dynamic> sent;
    final auth = AuthService(
      baseUrl: 'http://example.test',
      client: MockClient((request) async {
        expect(request.url.toString(), 'http://example.test/api/login');
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'username': 'doctor',
            'role': 'doctor',
            'fullName': 'Demo Doctor',
            'token': 'test-token',
          }),
          200,
        );
      }),
    );

    final user = await auth.signIn(' doctor ', 'Doctor123!');

    expect(sent['username'], 'doctor');
    expect(sent['password'], 'Doctor123!');
    expect(user.username, 'doctor');
    expect(user.roleLabel, 'Doctor');
    expect(user.dashboardLabel, 'Doctor dashboard');
    expect(user.token, 'test-token');
  });

  test('turns HTTP 401 into a login error', () async {
    final auth = AuthService(
      client: MockClient((request) async => http.Response('{}', 401)),
    );

    expect(
      auth.signIn('doctor', 'wrong'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Username or password is incorrect.',
        ),
      ),
    );
  });

  test('reports a clear message when the server cannot be reached', () async {
    final auth = AuthService(
      client: MockClient((request) async {
        throw http.ClientException('down');
      }),
    );

    expect(
      auth.signIn('doctor', 'Doctor123!'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          contains('Check your connection'),
        ),
      ),
    );
  });

  test('posts a new account and rejects a username that is already used', () async {
    late Map<String, dynamic> sent;
    final auth = AuthService(
      baseUrl: 'http://example.test',
      client: MockClient((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        if (sent['username'] == 'doctor') {
          return http.Response(
            jsonEncode({'message': 'That username is already used.'}),
            409,
          );
        }
        return http.Response(
          jsonEncode({
            'username': sent['username'],
            'role': sent['role'],
            'fullName': sent['username'],
            'token': 'new-token',
          }),
          201,
        );
      }),
    );

    await expectLater(
      auth.signUp(
        email: 'doctor@telemedicine.local',
        username: 'doctor',
        password: 'Doctor123!',
        role: 'doctor',
      ),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'That username is already used.',
        ),
      ),
    );

    final user = await auth.signUp(
      email: 'new@telemedicine.local',
      username: 'newperson',
      password: 'NewPass123',
      role: 'patient',
    );

    expect(sent['email'], 'new@telemedicine.local');
    expect(sent['username'], 'newperson');
    expect(sent['password'], 'NewPass123');
    expect(sent['role'], 'patient');
    expect(user.username, 'newperson');
    expect(user.token, 'new-token');
  });
}
