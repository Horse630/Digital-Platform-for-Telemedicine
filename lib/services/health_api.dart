import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class HealthReadingRecord {
  const HealthReadingRecord({
    required this.metric,
    required this.value,
    required this.unit,
  });

  final String metric;
  final num value;
  final String unit;

  factory HealthReadingRecord.fromJson(Map<String, dynamic> json) {
    return HealthReadingRecord(
      metric: json['metric'] is String ? json['metric'] as String : '',
      value: json['value'] is num ? json['value'] as num : 0,
      unit: json['unit'] is String ? json['unit'] as String : '',
    );
  }
}

class HealthException implements Exception {
  const HealthException(this.message);

  final String message;
}

class HealthApi {
  const HealthApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<List<HealthReadingRecord>> list() async {
    final decoded = await _send('GET', '/api/health-readings');
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(HealthReadingRecord.fromJson)
        .toList();
  }

  Future<void> save({required String metric, required num value}) {
    return _send(
      'POST',
      '/api/health-readings',
      body: {'metric': metric, 'value': value},
    );
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final root = authService.baseUrl ?? apiBaseUrl;
    final client = authService.client ?? AuthService.sharedClient;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    try {
      final http.Response response;
      if (method == 'GET') {
        response = await client
            .get(Uri.parse('$root$path'), headers: headers)
            .timeout(const Duration(seconds: 8));
      } else {
        response = await client
            .post(
              Uri.parse('$root$path'),
              headers: headers,
              body: jsonEncode(body ?? <String, Object?>{}),
            )
            .timeout(const Duration(seconds: 8));
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return jsonDecode(response.body);
      }
      throw HealthException(_message(response.body));
    } on HealthException {
      rethrow;
    } catch (_) {
      throw const HealthException(
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
    return 'The health request failed.';
  }
}
