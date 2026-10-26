import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

/// One appointment row returned by the Node API.
class AppointmentRecord {
  const AppointmentRecord({
    required this.id,
    required this.scheduledAt,
    required this.status,
    required this.reason,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
  });

  final String id;
  final DateTime scheduledAt;
  final String status;
  final String reason;
  final String doctorName;
  final String doctorSpecialty;
  final String? patientName;

  factory AppointmentRecord.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'];
    final patient = json['patient'];
    if (doctor is! Map<String, dynamic>) {
      throw const AppointmentException(
        'The appointment list could not be read.',
      );
    }
    final id = json['id'];
    final scheduledAt = json['scheduledAt'];
    final status = json['status'];
    final doctorName = doctor['fullName'];
    if (id is! String ||
        scheduledAt is! String ||
        status is! String ||
        doctorName is! String) {
      throw const AppointmentException(
        'The appointment list could not be read.',
      );
    }
    return AppointmentRecord(
      id: id,
      scheduledAt: DateTime.parse(scheduledAt),
      status: status,
      reason: json['reason'] is String ? json['reason'] as String : '',
      doctorName: doctorName,
      doctorSpecialty: doctor['specialty'] is String
          ? doctor['specialty'] as String
          : '',
      patientName:
          patient is Map<String, dynamic> && patient['fullName'] is String
          ? patient['fullName'] as String
          : null,
    );
  }
}

class AppointmentException implements Exception {
  const AppointmentException(this.message);

  final String message;
}

/// Reads and changes appointments for the signed-in account.
class AppointmentApi {
  const AppointmentApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<List<AppointmentRecord>> list() {
    return _send('GET', '/api/appointments');
  }

  Future<void> addSlot(DateTime scheduledAt) {
    return _send(
      'POST',
      '/api/appointments',
      body: {'scheduledAt': scheduledAt.toUtc().toIso8601String()},
    );
  }

  Future<void> book(String id, String reason) {
    return _send(
      'POST',
      '/api/appointments/$id/book',
      body: {'reason': reason},
    );
  }

  Future<void> cancel(String id) {
    return _send('POST', '/api/appointments/$id/cancel');
  }

  Future<List<AppointmentRecord>> _send(
    String method,
    String path, {
    Map<String, String>? body,
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
      } else {
        response = await client
            .post(
              uri,
              headers: headers,
              body: jsonEncode(body ?? <String, String>{}),
            )
            .timeout(const Duration(seconds: 8));
      }
      return _read(response.statusCode, response.body, method);
    } on AppointmentException {
      rethrow;
    } on TimeoutException {
      throw const AppointmentException(
        'Cannot reach the server. Start it with npm start in the backend folder.',
      );
    } catch (error) {
      if (error is AppointmentException) {
        rethrow;
      }
      throw const AppointmentException(
        'Cannot reach the server. Start it with npm start in the backend folder.',
      );
    }
  }

  List<AppointmentRecord> _read(int statusCode, String body, String method) {
    if (statusCode >= 200 && statusCode < 300) {
      if (method != 'GET') {
        return const [];
      }
      final decoded = jsonDecode(body);
      if (decoded is! List) {
        throw const AppointmentException(
          'The appointment list could not be read.',
        );
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AppointmentRecord.fromJson)
          .toList();
    }
    throw AppointmentException(_message(body));
  }

  String _message(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_error) {
      // A failed response may have an empty body.
    }
    return 'The appointment request failed.';
  }
}
