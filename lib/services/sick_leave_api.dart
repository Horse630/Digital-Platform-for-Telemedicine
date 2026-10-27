import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class SickLeavePerson {
  const SickLeavePerson({
    required this.id,
    required this.fullName,
    required this.licenseNumber,
  });

  final String id;
  final String fullName;
  final String licenseNumber;

  static const empty = SickLeavePerson(id: '', fullName: '', licenseNumber: '');

  factory SickLeavePerson.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return empty;
    }
    final id = json['id'];
    final fullName = json['fullName'];
    if (id is! String || fullName is! String) {
      return empty;
    }
    return SickLeavePerson(
      id: id,
      fullName: fullName,
      licenseNumber: json['licenseNumber'] is String
          ? json['licenseNumber'] as String
          : '',
    );
  }
}

class SickLeaveCertificate {
  const SickLeaveCertificate({
    required this.id,
    required this.certificateNumber,
    required this.appointmentId,
    required this.issuedOn,
    required this.validFrom,
    required this.validTo,
    required this.dayCount,
    required this.patientAddress,
    required this.unfitFor,
    required this.summary,
    required this.signature,
    required this.patient,
    required this.doctor,
  });

  final String id;
  final String certificateNumber;
  final String appointmentId;
  final DateTime issuedOn;
  final DateTime validFrom;
  final DateTime validTo;
  final int dayCount;
  final String patientAddress;
  final String unfitFor;
  final String summary;
  final String signature;
  final SickLeavePerson patient;
  final SickLeavePerson doctor;

  factory SickLeaveCertificate.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final number = json['certificateNumber'];
    final issuedOn = json['issuedOn'];
    final validFrom = json['validFrom'];
    final validTo = json['validTo'];
    final summary = json['summary'];
    if (id is! String ||
        number is! String ||
        issuedOn is! String ||
        validFrom is! String ||
        validTo is! String ||
        summary is! String) {
      throw const SickLeaveException('The sick leave list could not be read.');
    }
    return SickLeaveCertificate(
      id: id,
      certificateNumber: number,
      appointmentId: json['appointmentId'] is String
          ? json['appointmentId'] as String
          : '',
      issuedOn: DateTime.parse(issuedOn),
      validFrom: DateTime.parse(validFrom),
      validTo: DateTime.parse(validTo),
      dayCount: json['dayCount'] is num ? (json['dayCount'] as num).toInt() : 1,
      patientAddress: json['patientAddress'] is String
          ? json['patientAddress'] as String
          : '',
      unfitFor: json['unfitFor'] is String ? json['unfitFor'] as String : '',
      summary: summary,
      signature: json['signature'] is String ? json['signature'] as String : '',
      patient: SickLeavePerson.fromJson(json['patient']),
      doctor: SickLeavePerson.fromJson(json['doctor']),
    );
  }
}

class SickLeaveException implements Exception {
  const SickLeaveException(this.message);

  final String message;
}

class SickLeaveApi {
  const SickLeaveApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<List<SickLeaveCertificate>> list() async {
    final decoded = jsonDecode(await _send('GET', '/api/sick-leave'));
    if (decoded is! List) {
      throw const SickLeaveException('The sick leave list could not be read.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SickLeaveCertificate.fromJson)
        .toList();
  }

  Future<SickLeaveCertificate> issue({
    required String appointmentId,
    required String patientAddress,
    required String unfitFor,
    required String validFrom,
    required String validTo,
    required String summary,
    required String signature,
  }) async {
    final decoded = jsonDecode(
      await _send('POST', '/api/sick-leave', jsonBody: {
        'appointmentId': appointmentId,
        'patientAddress': patientAddress,
        'unfitFor': unfitFor,
        'validFrom': validFrom,
        'validTo': validTo,
        'summary': summary,
        'signature': signature,
      }),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const SickLeaveException('The sick leave request failed.');
    }
    return SickLeaveCertificate.fromJson(decoded);
  }

  Future<String> _send(
    String method,
    String path, {
    Map<String, String>? jsonBody,
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
            .post(uri, headers: headers, body: jsonEncode(jsonBody ?? {}))
            .timeout(const Duration(seconds: 8));
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
      throw SickLeaveException(_message(response.body));
    } on SickLeaveException {
      rethrow;
    } on TimeoutException {
      throw const SickLeaveException(
        'Cannot reach the service. Check your connection and try again.',
      );
    } catch (error) {
      if (error is SickLeaveException) {
        rethrow;
      }
      throw const SickLeaveException(
        'Cannot reach the service. Check your connection and try again.',
      );
    }
  }

  String _message(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {
      // A failed response may have an empty body.
    }
    return 'The sick leave request failed.';
  }
}
