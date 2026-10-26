import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Account returned by POST /api/login. The password hash stays on the server.
class SignedInUser {
  const SignedInUser({
    required this.username,
    required this.role,
    required this.fullName,
    required this.token,
  });

  final String username;
  final String role;
  final String fullName;
  final String token;

  /// Used after the settings page changes the username or receives a new token.
  SignedInUser copyWith({String? username, String? token}) {
    return SignedInUser(
      username: username ?? this.username,
      role: role,
      fullName: fullName,
      token: token ?? this.token,
    );
  }

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'doctor':
        return 'Doctor';
      case 'patient':
        return 'Patient';
      default:
        return role;
    }
  }

  String get dashboardLabel {
    switch (role) {
      case 'admin':
        return 'Admin dashboard';
      case 'doctor':
        return 'Doctor dashboard';
      default:
        return 'Patient dashboard';
    }
  }
}

/// Shown on the login form when sign-in cannot finish.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

/// Asks the Node API to check a username and password in MongoDB.
class AuthService {
  const AuthService({this.client, this.baseUrl});

  final http.Client? client;
  final String? baseUrl;

  static final http.Client sharedClient = http.Client();

  Future<SignedInUser> signIn(String username, String password) async {
    final http.Client httpClient = client ?? sharedClient;
    final root = baseUrl ?? apiBaseUrl;

    try {
      final response = await httpClient
          .post(
            Uri.parse('$root/api/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return _userFromBody(response.body);
      }
      if (response.statusCode == 401) {
        throw const AuthException('Username or password is incorrect.');
      }
      throw const AuthException('Sign-in failed. Try again.');
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'Cannot reach the service. Check your connection and try again.',
      );
    } catch (_error) {
      throw const AuthException(
        'Cannot reach the service. Check your connection and try again.',
      );
    }
  }

  /// Creates a patient or doctor account, then returns the signed-in user.
  ///
  /// Patient and doctor send the same fields. The server rejects a username
  /// that already exists, ignoring letter case.
  Future<SignedInUser> signUp({
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    final http.Client httpClient = client ?? sharedClient;
    final root = baseUrl ?? apiBaseUrl;

    try {
      final response = await httpClient
          .post(
            Uri.parse('$root/api/signup'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'username': username.trim(),
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201) {
        return _userFromBody(response.body);
      }
      throw AuthException(_message(response.body, 'Could not create the account.'));
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'Cannot reach the service. Check your connection and try again.',
      );
    } catch (_error) {
      throw const AuthException(
        'Cannot reach the service. Check your connection and try again.',
      );
    }
  }

  SignedInUser _userFromBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthException('Sign-in failed. Try again.');
    }
    final username = decoded['username'];
    final role = decoded['role'];
    final fullName = decoded['fullName'];
    final token = decoded['token'];
    if (username is! String ||
        role is! String ||
        fullName is! String ||
        token is! String ||
        token.isEmpty) {
      throw const AuthException('Sign-in failed. Try again.');
    }
    return SignedInUser(
      username: username,
      role: role,
      fullName: fullName,
      token: token,
    );
  }

  String _message(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_error) {
      // A failed response may have an empty body.
    }
    return fallback;
  }
}
