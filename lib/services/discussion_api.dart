import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class DiscussionPerson {
  const DiscussionPerson({
    required this.id,
    required this.fullName,
    required this.avatarBase64,
    required this.role,
    required this.description,
    required this.specialties,
    required this.allergies,
  });

  final String id;
  final String fullName;
  final String avatarBase64;
  final String role;
  final String description;
  final List<String> specialties;
  final List<String> allergies;

  static const empty = DiscussionPerson(
    id: '',
    fullName: '',
    avatarBase64: '',
    role: '',
    description: '',
    specialties: [],
    allergies: [],
  );

  factory DiscussionPerson.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return empty;
    }
    final id = json['id'];
    final fullName = json['fullName'];
    if (id is! String || fullName is! String) {
      return empty;
    }
    return DiscussionPerson(
      id: id,
      fullName: fullName,
      avatarBase64: json['avatarBase64'] is String
          ? json['avatarBase64'] as String
          : '',
      role: json['role'] is String ? json['role'] as String : '',
      description: json['description'] is String ? json['description'] as String : '',
      specialties: _strings(json['specialties']),
      allergies: _strings(json['allergies']),
    );
  }
}

List<String> _strings(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final item in value)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
}

class DiscussionTopic {
  const DiscussionTopic({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.patient,
    required this.doctor,
    required this.commentCount,
    required this.unreadCount,
    required this.repliedByMe,
  });

  final String id;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;
  final DiscussionPerson patient;
  final DiscussionPerson doctor;
  final int commentCount;
  final int unreadCount;
  final bool repliedByMe;

  factory DiscussionTopic.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final body = json['body'];
    final status = json['status'];
    final createdAt = json['createdAt'];
    if (id is! String ||
        title is! String ||
        body is! String ||
        status is! String ||
        createdAt is! String) {
      throw const DiscussionException('The discussion list could not be read.');
    }
    return DiscussionTopic(
      id: id,
      title: title,
      body: body,
      status: status,
      createdAt: DateTime.parse(createdAt),
      patient: DiscussionPerson.fromJson(json['patient']),
      doctor: DiscussionPerson.fromJson(json['doctor']),
      commentCount: json['commentCount'] is num
          ? (json['commentCount'] as num).toInt()
          : 0,
      unreadCount: json['unreadCount'] is num
          ? (json['unreadCount'] as num).toInt()
          : 0,
      repliedByMe: json['repliedByMe'] == true,
    );
  }
}

class DiscussionReply {
  const DiscussionReply({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.author,
    required this.likeCount,
    required this.liked,
    required this.stored,
  });

  final String id;
  final String body;
  final DateTime createdAt;
  final DiscussionPerson author;
  final int likeCount;
  final bool liked;
  final bool stored;

  factory DiscussionReply.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final body = json['body'];
    final createdAt = json['createdAt'];
    if (id is! String || body is! String || createdAt is! String) {
      throw const DiscussionException('The discussion list could not be read.');
    }
    return DiscussionReply(
      id: id,
      body: body,
      createdAt: DateTime.parse(createdAt),
      author: DiscussionPerson.fromJson(json['author']),
      likeCount: json['likeCount'] is num ? (json['likeCount'] as num).toInt() : 0,
      liked: json['liked'] == true,
      stored: json['stored'] == true,
    );
  }
}

class DiscussionThread {
  const DiscussionThread({required this.topic, required this.replies});

  final DiscussionTopic topic;
  final List<DiscussionReply> replies;
}

class DiscussionException implements Exception {
  const DiscussionException(this.message);

  final String message;
}

class DiscussionApi {
  const DiscussionApi({required this.authService, required this.token});

  final AuthService authService;
  final String token;

  Future<List<DiscussionTopic>> list() async {
    final decoded = jsonDecode(await _send('GET', '/api/discussions'));
    if (decoded is! List) {
      throw const DiscussionException('The discussion list could not be read.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DiscussionTopic.fromJson)
        .toList();
  }

  Future<DiscussionThread> thread(String id) async {
    final decoded = jsonDecode(await _send('GET', '/api/discussions/$id'));
    if (decoded is! Map<String, dynamic> ||
        decoded['discussion'] is! Map<String, dynamic> ||
        decoded['comments'] is! List) {
      throw const DiscussionException('The discussion list could not be read.');
    }
    return DiscussionThread(
      topic: DiscussionTopic.fromJson(
        decoded['discussion'] as Map<String, dynamic>,
      ),
      replies: (decoded['comments'] as List)
          .whereType<Map<String, dynamic>>()
          .map(DiscussionReply.fromJson)
          .toList(),
    );
  }

  Future<DiscussionTopic> ask({
    required String title,
    required String body,
  }) async {
    final decoded = jsonDecode(
      await _send('POST', '/api/discussions', jsonBody: {
        'title': title,
        'body': body,
      }),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const DiscussionException('The discussion request failed.');
    }
    return DiscussionTopic.fromJson(decoded);
  }

  Future<DiscussionReply> reply(String id, String body) async {
    final decoded = jsonDecode(
      await _send('POST', '/api/discussions/$id/comments', jsonBody: {
        'body': body,
      }),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const DiscussionException('The discussion request failed.');
    }
    return DiscussionReply.fromJson(decoded);
  }

  Future<DiscussionReply> like(String topicId, String commentId) {
    return _comment(topicId, commentId, 'like');
  }

  Future<DiscussionReply> store(String topicId, String commentId) {
    return _comment(topicId, commentId, 'save');
  }

  Future<void> remove(String id) {
    return _send('DELETE', '/api/discussions/$id');
  }

  Future<DiscussionReply> updateReply(
    String topicId,
    String commentId,
    String body,
  ) async {
    final decoded = jsonDecode(
      await _send(
        'PATCH',
        '/api/discussions/$topicId/comments/$commentId',
        jsonBody: {'body': body},
      ),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const DiscussionException('The discussion request failed.');
    }
    return DiscussionReply.fromJson(decoded);
  }

  Future<void> removeReply(String topicId, String commentId) {
    return _send('DELETE', '/api/discussions/$topicId/comments/$commentId');
  }

  Future<DiscussionReply> _comment(
    String topicId,
    String commentId,
    String action,
  ) async {
    final decoded = jsonDecode(
      await _send(
        'POST',
        '/api/discussions/$topicId/comments/$commentId/$action',
      ),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const DiscussionException('The discussion request failed.');
    }
    return DiscussionReply.fromJson(decoded);
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
      } else if (method == 'DELETE') {
        response = await client
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 8));
      } else if (method == 'PATCH') {
        response = await client
            .patch(uri, headers: headers, body: jsonEncode(jsonBody ?? {}))
            .timeout(const Duration(seconds: 8));
      } else {
        response = await client
            .post(uri, headers: headers, body: jsonEncode(jsonBody ?? {}))
            .timeout(const Duration(seconds: 8));
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
      throw DiscussionException(_message(response.body));
    } on DiscussionException {
      rethrow;
    } on TimeoutException {
      throw const DiscussionException(
        'Cannot reach the service. Check your connection and try again.',
      );
    } catch (error) {
      if (error is DiscussionException) {
        rethrow;
      }
      throw const DiscussionException(
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
    return 'The discussion request failed.';
  }
}
