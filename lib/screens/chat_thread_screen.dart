import 'dart:async';

import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/message_api.dart';
import '../widgets/account_avatar.dart';

/// Opens a direct conversation with one person.
Future<void> openDirectChat(
  BuildContext context, {
  required AuthService authService,
  required String token,
  required String userId,
  required String fullName,
  required String avatarBase64,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ChatThreadScreen(
        authService: authService,
        token: token,
        userId: userId,
        fullName: fullName,
        avatarBase64: avatarBase64,
      ),
    ),
  );
}

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.authService,
    required this.token,
    required this.userId,
    required this.fullName,
    required this.avatarBase64,
  });

  final AuthService authService;
  final String token;
  final String userId;
  final String fullName;
  final String avatarBase64;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final MessageApi _api = MessageApi(
    authService: widget.authService,
    token: widget.token,
  );
  final _text = TextEditingController();
  final _lines = <ChatLine>[];

  bool _loading = true;
  bool _sending = false;
  bool _refreshing = false;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;
    try {
      final lines = await _api.thread(widget.userId);
      if (!mounted) {
        return;
      }
      setState(() {
        _lines
          ..clear()
          ..addAll(lines);
        _error = null;
      });
    } on MessageException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      _refreshing = false;
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      final sent = await _api.send(widget.userId, text);
      if (!mounted) {
        return;
      }
      _text.clear();
      setState(() {
        _lines.add(sent);
        _error = null;
      });
    } on MessageException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AccountAvatar(avatarBase64: widget.avatarBase64, radius: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.fullName, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _transcript(l10n)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: l10n.messageHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.send,
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transcript(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _lines.isEmpty) {
      return Center(child: Text(localizeMessage(l10n, _error!)));
    }
    if (_lines.isEmpty) {
      return Center(child: Text(l10n.noMessages));
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        final line = _lines[_lines.length - 1 - index];
        return _Bubble(line: line, l10n: l10n);
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.line, required this.l10n});

  final ChatLine line;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final local = line.sentAt.toLocal();
    final time = TimeOfDay.fromDateTime(local).format(context);
    return Align(
      alignment: line.fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: line.fromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: line.fromMe
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(line.text),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (line.fromMe) ...[
                  const SizedBox(width: 2),
                  Tooltip(
                    message: line.read ? l10n.messageRead : l10n.messageSent,
                    child: Icon(
                      line.read ? Icons.done_all : Icons.done,
                      size: 16,
                      color: line.read
                          ? const Color(0xFF34B7F1)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
