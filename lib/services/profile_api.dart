import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

/// Profile fields stored on the signed-in user document.
class ProfileDetails {
  const ProfileDetails({
    required this.username,
    required this.role,
    required this.fullName,
    required this.description,
    required this.avatarBase64,
    required this.avatarMime,
    this.specialties = const [],
    this.allergies = const [],
    this.deliveryAddress = '',
    this.token,
  });

  final String username;
  final String role;
  final String fullName;
  final String description;
  final String avatarBase64;
  final String avatarMime;
  final List<String> specialties;
  final List<String> allergies;
  final String deliveryAddress;
  final String? token;

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
    final username = json['username'];
    final role = json['role'];
    final fullName = json['fullName'];
    if (username is! String || role is! String || fullName is! String) {
      throw const ProfileException('The profile could not be read.');
    }
    final token = json['token'];
    return ProfileDetails(
      username: username,
      role: role,
      fullName: fullName,
      description: json['description'] is String
          ? json['description'] as String
          : '',
      avatarBase64: json['avatarBase64'] is String
          ? json['avatarBase64'] as String
          : '',
      avatarMime: json['avatarMime'] is String
          ? json['avatarMime'] as String
          : '',
      specialties: _stringList(json['specialties']),
      allergies: _stringList(json['allergies']),
      deliveryAddress: json['deliveryAddress'] is String
          ? json['deliveryAddress'] as String
          : '',
      token: token is String && token.isNotEmpty ? token : null,
    );
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;
}

/// Reads and updates the signed-in account in the users collection.
class ProfileApi {
  const ProfileApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<ProfileDetails> load() {
    return _send('GET', '/api/profile');
  }

  Future<ProfileDetails> save({
    required String username,
    required String description,
    required String avatarBase64,
    required String avatarMime,
    List<String> specialties = const [],
    List<String> allergies = const [],
    String deliveryAddress = '',
  }) {
    return _send(
      'PATCH',
      '/api/profile',
      body: {
        'username': username.trim(),
        'description': description.trim(),
        'avatarBase64': avatarBase64,
        'avatarMime': avatarMime,
        'specialties': specialties,
        'allergies': allergies,
        'deliveryAddress': deliveryAddress.trim(),
      },
    );
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final details = await _send(
      'POST',
      '/api/profile/password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      messageOnly: true,
    );
    // The password route returns {message}. That text is carried in description.
    return details.description;
  }

  Future<ProfileDetails> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool messageOnly = false,
  }) async {
    final root = authService.baseUrl ?? apiBaseUrl;
    final client = authService.client ?? AuthService.sharedClient;
    final uri = Uri.parse('$root$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final http.Response response;
      if (method == 'GET') {
        response = await client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 8));
      } else if (method == 'PATCH') {
        response = await client
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 8));
      } else {
        response = await client
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 8));
      }
      return _read(response.statusCode, response.body, messageOnly);
    } on ProfileException {
      rethrow;
    } on TimeoutException {
      throw const ProfileException(
        'Cannot reach the service. Check your connection and try again.',
      );
    } catch (error) {
      if (error is ProfileException) {
        rethrow;
      }
      throw const ProfileException(
        'Cannot reach the service. Check your connection and try again.',
      );
    }
  }

  ProfileDetails _read(int statusCode, String body, bool messageOnly) {
    if (statusCode >= 200 && statusCode < 300) {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const ProfileException('The profile could not be read.');
      }
      if (messageOnly) {
        final message = decoded['message'];
        return ProfileDetails(
          username: '',
          role: '',
          fullName: '',
          description: message is String ? message : 'Password updated.',
          avatarBase64: '',
          avatarMime: '',
        );
      }
      return ProfileDetails.fromJson(decoded);
    }
    throw ProfileException(_message(statusCode, body));
  }

  String _message(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {
      // A failed response may have an empty body.
    }
    if (statusCode == 404) {
      return 'The account service is not available. Try again later.';
    }
    return 'The profile request failed.';
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList();
}
