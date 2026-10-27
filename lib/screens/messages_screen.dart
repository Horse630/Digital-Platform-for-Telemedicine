import 'dart:async';

import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/message_api.dart';
import '../widgets/account_avatar.dart';
import 'chat_thread_screen.dart';

/// Inbox of people this account has messaged, or who have messaged them.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.authService,
    required this.token,
    required this.active,
    required this.onUnreadChanged,
  });

  final AuthService authService;
  final String token;
  final bool active;
  final ValueChanged<int> onUnreadChanged;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late MessageApi _api = MessageApi(
    authService: widget.authService,
    token: widget.token,
  );
  List<ConversationPreview> _conversations = const [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _api = MessageApi(authService: widget.authService, token: widget.token);
    }
    if (widget.active && !oldWidget.active) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;
    try {
      final conversations = await _api.conversations();
      if (!mounted) {
        return;
      }
      final unread = conversations.fold<int>(
        0,
        (total, conversation) => total + conversation.unread,
      );
      setState(() {
        _conversations = conversations;
        _error = null;
      });
      widget.onUnreadChanged(unread);
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

  Future<void> _open(ConversationPreview conversation) async {
    await openDirectChat(
      context,
      authService: widget.authService,
      token: widget.token,
      userId: conversation.userId,
      fullName: conversation.fullName,
      avatarBase64: conversation.avatarBase64,
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading && _conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(localizeMessage(l10n, _error!), textAlign: TextAlign.center),
        ),
      );
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(l10n.noMessages, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.noMessagesHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _conversations.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _ConversationTile(
          conversation: conversation,
          when: _when(context, conversation.sentAt),
          onTap: () => _open(conversation),
        );
      },
    );
  }

  String _when(BuildContext context, DateTime sentAt) {
    final local = sentAt.toLocal();
    final now = DateTime.now();
    final time = TimeOfDay.fromDateTime(local).format(context);
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (sameDay) {
      return time;
    }
    return MaterialLocalizations.of(context).formatMediumDate(local);
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.when,
    required this.onTap,
  });

  final ConversationPreview conversation;
  final String when;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unread;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AccountAvatar(avatarBase64: conversation.avatarBase64, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  when,
                  style: TextStyle(
                    fontSize: 12,
                    color: unread > 0 ? const Color(0xFF25D366) : scheme.onSurfaceVariant,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  _UnreadCount(count: unread),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadCount extends StatelessWidget {
  const _UnreadCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF25D366),
        borderRadius: BorderRadius.all(Radius.circular(11)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
