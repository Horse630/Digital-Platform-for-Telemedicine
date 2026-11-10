import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class DeliveryRecord {
  const DeliveryRecord({
    required this.id,
    required this.medicationName,
    required this.quantity,
    required this.status,
    required this.destination,
  });

  final String id;
  final String medicationName;
  final int quantity;
  final String status;
  final String destination;

  factory DeliveryRecord.fromJson(Map<String, dynamic> json) {
    return DeliveryRecord(
      id: json['id'] is String ? json['id'] as String : '',
      medicationName: json['medicationName'] is String
          ? json['medicationName'] as String
          : '',
      quantity: json['quantity'] is int ? json['quantity'] as int : 1,
      status: json['status'] is String ? json['status'] as String : 'preparing',
      destination: json['destination'] is String
          ? json['destination'] as String
          : '',
    );
  }
}

class DeliveryException implements Exception {
  const DeliveryException(this.message);

  final String message;
}

class DeliveryApi {
  const DeliveryApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<List<DeliveryRecord>> list() async {
    final decoded = await _send('GET', '/api/deliveries');
    if (decoded is! List) {
      return const [];
    }
    return decoded.whereType<Map<String, dynamic>>().map(DeliveryRecord.fromJson).toList();
  }

  Future<void> create({
    required String appointmentId,
    required String medicationName,
    required int quantity,
  }) {
    return _send(
      'POST',
      '/api/deliveries',
      body: {
        'appointmentId': appointmentId,
        'medicationName': medicationName,
        'quantity': quantity,
      },
    );
  }

  Future<void> advance(String id) {
    return _send('POST', '/api/deliveries/$id/advance');
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
      throw DeliveryException(_message(response.body));
    } on DeliveryException {
      rethrow;
    } catch (_) {
      throw const DeliveryException(
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
    return 'The delivery request failed.';
  }
}
