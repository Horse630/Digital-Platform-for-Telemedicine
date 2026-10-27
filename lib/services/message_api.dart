import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class ConversationPreview {
  const ConversationPreview({
    required this.userId,
    required this.fullName,
    required this.avatarBase64,
    required this.text,
    required this.sentAt,
    required this.unread,
  });

  final String userId;
  final String fullName;
  final String avatarBase64;
  final String text;
  final DateTime sentAt;
  final int unread;

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final sentAt = json['sentAt'];
    if (user is! Map<String, dynamic> || sentAt is! String) {
      throw const MessageException('The message list could not be read.');
    }
    final id = user['id'];
    final fullName = user['fullName'];
    if (id is! String || fullName is! String) {
      throw const MessageException('The message list could not be read.');
    }
    return ConversationPreview(
      userId: id,
      fullName: fullName,
      avatarBase64: user['avatarBase64'] is String
          ? user['avatarBase64'] as String
          : '',
      text: json['text'] is String ? json['text'] as String : '',
      sentAt: DateTime.parse(sentAt),
      unread: json['unread'] is num ? (json['unread'] as num).toInt() : 0,
    );
  }
}

class ChatLine {
  const ChatLine({
    required this.id,
    required this.text,
    required this.fromMe,
    required this.sentAt,
    required this.read,
  });

  final String id;
  final String text;
  final bool fromMe;
  final DateTime sentAt;
  final bool read;

  factory ChatLine.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    final sentAt = json['sentAt'];
    if (id is! String || text is! String || sentAt is! String) {
      throw const MessageException('The message list could not be read.');
    }
    return ChatLine(
      id: id,
      text: text,
      fromMe: json['fromMe'] == true,
      sentAt: DateTime.parse(sentAt),
      read: json['read'] == true,
    );
  }
}

class MessageException implements Exception {
  const MessageException(this.message);

  final String message;
}

class MessageApi {
  const MessageApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<List<ConversationPreview>> conversations() async {
    final body = await _send('GET', '/api/messages');
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw const MessageException('The message list could not be read.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ConversationPreview.fromJson)
        .toList();
  }

  Future<List<ChatLine>> thread(String userId) async {
    final body = await _send('GET', '/api/messages/$userId');
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic> || decoded['messages'] is! List) {
      throw const MessageException('The message list could not be read.');
    }
    return (decoded['messages'] as List)
        .whereType<Map<String, dynamic>>()
        .map(ChatLine.fromJson)
        .toList();
  }

  Future<ChatLine> send(String userId, String text) async {
    final body = await _send(
      'POST',
      '/api/messages/$userId',
      jsonBody: {'text': text},
    );
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const MessageException('The message request failed.');
    }
    return ChatLine.fromJson(decoded);
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
      throw MessageException(_message(response.body));
    } on MessageException {
      rethrow;
    } on TimeoutException {
      throw const MessageException(
        'Cannot reach the service. Check your connection and try again.',
      );
    } catch (error) {
      if (error is MessageException) {
        rethrow;
      }
      throw const MessageException(
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
    return 'The message request failed.';
  }
}
