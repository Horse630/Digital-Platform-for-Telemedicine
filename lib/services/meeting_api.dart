import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class MeetingRecord {
  const MeetingRecord({
    required this.appointmentId,
    required this.scheduledAt,
    required this.patientName,
    required this.doctorName,
    required this.roomCode,
    required this.status,
    required this.waiting,
    required this.admitted,
  });

  final String appointmentId;
  final DateTime scheduledAt;
  final String patientName;
  final String doctorName;
  final String roomCode;
  final String status;
  final bool waiting;
  final bool admitted;

  bool get isOpen => status == 'live';

  factory MeetingRecord.fromJson(Map<String, dynamic> json) {
    final appointmentId = json['appointmentId'];
    final scheduledAt = json['scheduledAt'];
    if (appointmentId is! String || scheduledAt is! String) {
      throw const MeetingException('The meeting request failed.');
    }
    final parsed = DateTime.tryParse(scheduledAt);
    if (parsed == null) {
      throw const MeetingException('The meeting request failed.');
    }
    return MeetingRecord(
      appointmentId: appointmentId,
      scheduledAt: parsed.toLocal(),
      patientName: json['patientName'] is String ? json['patientName'] as String : '',
      doctorName: json['doctorName'] is String ? json['doctorName'] as String : '',
      roomCode: json['roomCode'] is String ? json['roomCode'] as String : '',
      status: json['status'] is String ? json['status'] as String : 'closed',
      waiting: json['waiting'] == true,
      admitted: json['admitted'] == true,
    );
  }
}

class MeetingList {
  const MeetingList({required this.roomCode, required this.meetings});

  final String roomCode;
  final List<MeetingRecord> meetings;
}

class MeetingException implements Exception {
  const MeetingException(this.message);

  final String message;
}

class MeetingApi {
  const MeetingApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<MeetingList> listToday(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query = 'from=${Uri.encodeQueryComponent(start.toUtc().toIso8601String())}'
        '&to=${Uri.encodeQueryComponent(end.toUtc().toIso8601String())}';
    return _list('/api/meetings?$query');
  }

  Future<MeetingList> listOpen() {
    return _list('/api/meetings');
  }

  Future<String> saveRoom(String roomCode) async {
    final decoded = await _send('PATCH', '/api/meetings/room', body: {'roomCode': roomCode});
    final code = decoded['roomCode'];
    if (code is! String) {
      throw const MeetingException('The meeting request failed.');
    }
    return code;
  }

  Future<MeetingRecord> host(String appointmentId) async {
    final decoded = await _send('POST', '/api/meetings/$appointmentId/host');
    return MeetingRecord.fromJson(decoded);
  }

  Future<MeetingRecord> join(String appointmentId) async {
    final decoded = await _send('POST', '/api/meetings/$appointmentId/join');
    return MeetingRecord.fromJson(decoded);
  }

  Future<MeetingRecord> admit(String appointmentId) async {
    final decoded = await _send('POST', '/api/meetings/$appointmentId/admit');
    return MeetingRecord.fromJson(decoded);
  }

  Future<MeetingRecord> end(String appointmentId) async {
    final decoded = await _send('POST', '/api/meetings/$appointmentId/end');
    return MeetingRecord.fromJson(decoded);
  }

  Future<MeetingRecord> read(String appointmentId) async {
    final decoded = await _send('GET', '/api/meetings/$appointmentId');
    return MeetingRecord.fromJson(decoded);
  }

  Future<MeetingList> _list(String path) async {
    final decoded = await _send('GET', path);
    final meetings = decoded['meetings'];
    final roomCode = decoded['roomCode'];
    if (meetings is! List) {
      throw const MeetingException('The meeting request failed.');
    }
    return MeetingList(
      roomCode: roomCode is String ? roomCode : '',
      meetings: [
        for (final item in meetings)
          if (item is Map<String, dynamic>) MeetingRecord.fromJson(item),
      ],
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
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
        response = await client.get(uri, headers: headers).timeout(const Duration(seconds: 8));
      } else if (method == 'PATCH') {
        response = await client
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 8));
      } else {
        response = await client
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 8));
      }
      final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        throw MeetingException(decoded['message'] as String);
      }
      throw const MeetingException('The meeting request failed.');
    } on MeetingException {
      rethrow;
    } on TimeoutException {
      throw const MeetingException('The meeting request failed.');
    } catch (error) {
      if (error is MeetingException) {
        rethrow;
      }
      throw const MeetingException('The meeting request failed.');
    }
  }
}
