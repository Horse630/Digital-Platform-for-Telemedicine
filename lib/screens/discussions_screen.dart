import 'dart:convert';

import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/discussion_api.dart';
import '../widgets/account_avatar.dart';
import 'chat_thread_screen.dart';

/// Public questions. A patient asks. A doctor's reply is visible to everyone.
class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final SignedInUser user;

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  String get _myId => userIdFromToken(widget.user.token);

  late final DiscussionApi _api = DiscussionApi(
    authService: widget.authService,
    token: widget.user.token,
  );
  List<DiscussionTopic> _topics = const [];
  bool _mineOnly = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final topics = await _api.list();
      if (!mounted) {
        return;
      }
      setState(() {
        _topics = topics;
        _error = null;
      });
    } on DiscussionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _ask() async {
    final posted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _AskQuestionPage(api: _api),
      ),
    );
    if (posted == true) {
      await _load();
    }
  }

  bool get _isDoctor => widget.user.role == 'doctor';

  List<DiscussionTopic> get _visibleTopics {
    if (!_mineOnly) {
      return _topics;
    }
    if (_isDoctor) {
      return [
        for (final topic in _topics)
          if (topic.repliedByMe) topic,
      ];
    }
    return [
      for (final topic in _topics)
        if (topic.patient.id == _myId) topic,
    ];
  }

  Future<void> _remove(DiscussionTopic topic) async {
    final confirmed = await confirmRemovePost(context);
    if (!confirmed || !mounted) {
      return;
    }
    try {
      await _api.remove(topic.id);
      if (mounted) {
        await _load();
      }
    } on DiscussionException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
    }
  }

  Future<void> _open(DiscussionTopic topic) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _DiscussionThreadPage(
          api: _api,
          topicId: topic.id,
          canReply: widget.user.role == 'doctor',
          authService: widget.authService,
          token: widget.user.token,
          userId: _myId,
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.discussion)),
      body: _body(l10n),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading && _topics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(localizeMessage(l10n, _error!), textAlign: TextAlign.center),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(l10n.noDiscussionsHint),
        if (widget.user.role == 'patient') ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _ask,
            icon: const Icon(Icons.add),
            label: Text(l10n.askQuestion),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.publicDiscussions),
              selected: !_mineOnly,
              onSelected: (_) => setState(() => _mineOnly = false),
            ),
            ChoiceChip(
              label: Text(_isDoctor ? l10n.myResponses : l10n.myDiscussions),
              selected: _mineOnly,
              onSelected: (_) => setState(() => _mineOnly = true),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_visibleTopics.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Text(
                _mineOnly
                    ? (_isDoctor ? l10n.noMyResponses : l10n.noMyDiscussions)
                    : l10n.noDiscussions,
              ),
            ),
          )
        else
          for (final topic in _visibleTopics) ...[
            _TopicCard(
              topic: topic,
              onTap: () => _open(topic),
              onRemove: topic.patient.id == _myId ? () => _remove(topic) : null,
              onPerson: (person) => _showPersonProfile(
                context,
                person,
                authService: widget.authService,
                token: widget.user.token,
                userId: _myId,
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.onTap,
    required this.onPerson,
    this.onRemove,
  });

  final DiscussionTopic topic;
  final VoidCallback onTap;
  final ValueChanged<DiscussionPerson> onPerson;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = topic.patient.fullName.isEmpty
        ? l10n.unknown
        : topic.patient.fullName;
    final answered = topic.status == 'answered';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PersonButton(
                    person: topic.patient,
                    onPressed: () => onPerson(topic.patient),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: topic.patient.id.isEmpty
                          ? null
                          : () => onPerson(topic.patient),
                      child: Text(name),
                    ),
                  ),
                  if (topic.unreadCount > 0) ...[
                    _UnreadCount(count: topic.unreadCount),
                    const SizedBox(width: 8),
                  ],
                  if (onRemove != null)
                    IconButton(
                      tooltip: l10n.remove,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                    ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      answered ? l10n.discussionAnswered : l10n.discussionOpen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(topic.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                topic.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.replyCount(topic.commentCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskQuestionPage extends StatefulWidget {
  const _AskQuestionPage({required this.api});

  final DiscussionApi api;

  @override
  State<_AskQuestionPage> createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<_AskQuestionPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.api.ask(title: _title.text, body: _body.text);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on DiscussionException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.askQuestion)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.questionTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n.questionBody,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(l10n.postQuestion),
          ),
        ],
      ),
    );
  }
}

class _DiscussionThreadPage extends StatefulWidget {
  const _DiscussionThreadPage({
    required this.api,
    required this.topicId,
    required this.canReply,
    required this.authService,
    required this.token,
    required this.userId,
  });

  final DiscussionApi api;
  final String topicId;
  final bool canReply;
  final AuthService authService;
  final String token;
  final String userId;

  @override
  State<_DiscussionThreadPage> createState() => _DiscussionThreadPageState();
}

class _DiscussionThreadPageState extends State<_DiscussionThreadPage> {
  final _reply = TextEditingController();
  DiscussionThread? _thread;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final thread = await widget.api.thread(widget.topicId);
      if (!mounted) {
        return;
      }
      setState(() {
        _thread = thread;
        _error = null;
      });
    } on DiscussionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _remove() async {
    final confirmed = await confirmRemovePost(context);
    if (!confirmed || !mounted) {
      return;
    }
    try {
      await widget.api.remove(widget.topicId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on DiscussionException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
    }
  }

  Future<void> _toggle(DiscussionReply reply, {required bool like}) async {
    try {
      final updated = like
          ? await widget.api.like(widget.topicId, reply.id)
          : await widget.api.store(widget.topicId, reply.id);
      final thread = _thread;
      if (!mounted || thread == null) {
        return;
      }
      setState(() {
        _thread = DiscussionThread(
          topic: thread.topic,
          replies: [
            for (final item in thread.replies)
              if (item.id == updated.id) updated else item,
          ],
        );
      });
    } on DiscussionException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
    }
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      await widget.api.reply(widget.topicId, text);
      if (!mounted) {
        return;
      }
      _reply.clear();
      await _load();
    } on DiscussionException catch (error) {
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
    final thread = _thread;
    return Scaffold(
      appBar: AppBar(
        title: Text(thread?.topic.title ?? l10n.discussion),
        actions: [
          if (thread != null && thread.topic.patient.id == widget.userId)
            IconButton(
              tooltip: l10n.remove,
              onPressed: _remove,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && thread == null
          ? Center(child: Text(localizeMessage(l10n, _error!)))
          : thread == null
          ? Center(child: Text(l10n.noDiscussions))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        thread.topic.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(thread.topic.body),
                      const SizedBox(height: 8),
                      _PersonButton(
                        person: thread.topic.patient,
                        onPressed: () => _showPersonProfile(
                          context,
                          thread.topic.patient,
                          authService: widget.authService,
                          token: widget.token,
                          userId: widget.userId,
                        ),
                        label: thread.topic.patient.fullName.isEmpty
                            ? l10n.unknown
                            : thread.topic.patient.fullName,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.publicReply,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (thread.replies.isEmpty)
                        Text(l10n.noRepliesYet)
                      else
                        for (final reply in thread.replies) ...[
                          _ReplyCard(
                            reply: reply,
                            onPerson: () => _showPersonProfile(
                              context,
                              reply.author,
                              authService: widget.authService,
                              token: widget.token,
                              userId: widget.userId,
                            ),
                            onLike: () => _toggle(reply, like: true),
                            onStore: () => _toggle(reply, like: false),
                          ),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
                ),
                if (widget.canReply)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _reply,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              decoration: InputDecoration(
                                hintText: l10n.replyHint,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.replyAction,
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
}

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({
    required this.reply,
    required this.onPerson,
    required this.onLike,
    required this.onStore,
  });

  final DiscussionReply reply;
  final VoidCallback onPerson;
  final VoidCallback onLike;
  final VoidCallback onStore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = reply.author.fullName.isEmpty
        ? l10n.unknown
        : reply.author.fullName;
    final role = reply.author.role.isEmpty
        ? ''
        : localizedRole(l10n, reply.author.role);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PersonButton(
              person: reply.author,
              onPressed: onPerson,
              label: role.isEmpty ? name : '$name · $role',
            ),
            const SizedBox(height: 8),
            Text(reply.body),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.likeAction,
                  onPressed: onLike,
                  icon: Icon(
                    reply.liked ? Icons.favorite : Icons.favorite_border,
                    color: reply.liked ? const Color(0xFFE53935) : null,
                  ),
                ),
                Text('${reply.likeCount}'),
                IconButton(
                  tooltip: reply.stored ? l10n.storedAction : l10n.storeAction,
                  onPressed: onStore,
                  icon: Icon(
                    reply.stored ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonButton extends StatelessWidget {
  const _PersonButton({
    required this.person,
    required this.onPressed,
    this.label,
  });

  final DiscussionPerson person;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final enabled = person.id.isNotEmpty;
    final avatar = AccountAvatar(avatarBase64: person.avatarBase64, radius: 16);
    final button = IconButton(
      onPressed: enabled ? onPressed : null,
      icon: avatar,
      tooltip: context.l10n.viewDoctorProfile,
    );
    final name = label;
    if (name == null) {
      return button;
    }
    return Row(
      children: [
        button,
        const SizedBox(width: 4),
        Flexible(
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Text(name, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ],
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
        color: Color(0xFFE53935),
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

Future<bool> confirmRemovePost(BuildContext context) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      final text = dialogContext.l10n;
      return AlertDialog(
        title: Text(text.confirmRemovePostTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text.confirmRemovePostMessage),
            const SizedBox(height: 20),
            Align(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.surfaceContainerHighest,
                  foregroundColor: scheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(text.keep),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(text.remove),
            ),
          ],
        ),
      );
    },
  );
  return answer ?? false;
}

void _showPersonProfile(
  BuildContext context,
  DiscussionPerson person, {
  required AuthService authService,
  required String token,
  required String userId,
}) {
  if (person.id.isEmpty) {
    return;
  }
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final text = dialogContext.l10n;
      final description = person.description.trim();
      final canMessage = person.id != userId;
      return AlertDialog(
        title: Text(
          person.role == 'doctor' ? text.doctorProfile : text.patientProfile,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccountAvatar(avatarBase64: person.avatarBase64, radius: 36),
              const SizedBox(height: 12),
              Text(
                person.fullName.isEmpty ? text.unknown : person.fullName,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.titleLarge,
              ),
              if (person.role.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(localizedRole(text, person.role)),
              ],
              if (person.specialties.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in person.specialties)
                      Chip(label: Text(localizedDoctorType(text, type))),
                  ],
                ),
              ],
              if (person.allergies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(text.allergies),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final allergy in person.allergies)
                      Chip(label: Text(allergy)),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(
                description.isEmpty ? text.noDescription : description,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          if (canMessage)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openDirectChat(
                  context,
                  authService: authService,
                  token: token,
                  userId: person.id,
                  fullName: person.fullName,
                  avatarBase64: person.avatarBase64,
                );
              },
              child: Text(text.messageAction),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(text.close),
          ),
        ],
      );
    },
  );
}

String userIdFromToken(String token) {
  final body = token.split('.').first;
  try {
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(body)));
    final json = jsonDecode(decoded);
    if (json is Map<String, dynamic> && json['sub'] is String) {
      return json['sub'] as String;
    }
  } catch (_) {
    return '';
  }
  return '';
}
