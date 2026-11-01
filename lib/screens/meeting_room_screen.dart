import 'dart:async';

import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/meeting_api.dart';

/// The room after a doctor hosts a visit or a patient joins one.
///
/// A patient stays in the waiting room until the doctor lets them in.
/// The two devices do not send a live picture.
class MeetingRoomScreen extends StatefulWidget {
  const MeetingRoomScreen({
    super.key,
    required this.authService,
    required this.token,
    required this.meeting,
    required this.host,
    required this.selfName,
  });

  final AuthService authService;
  final String token;
  final MeetingRecord meeting;
  final bool host;
  final String selfName;

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  late MeetingRecord _meeting = widget.meeting;
  Timer? _poll;
  String? _error;

  MeetingApi get _api => MeetingApi(authService: widget.authService, token: widget.token);

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final next = await _api.read(_meeting.appointmentId);
      if (!mounted) {
        return;
      }
      setState(() => _meeting = next);
    } on MeetingException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _admit() async {
    try {
      final next = await _api.admit(_meeting.appointmentId);
      if (mounted) {
        setState(() => _meeting = next);
      }
    } on MeetingException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _end() async {
    try {
      final next = await _api.end(_meeting.appointmentId);
      if (mounted) {
        setState(() => _meeting = next);
      }
    } on MeetingException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final ended = _meeting.status == 'ended';
    final inRoom = widget.host || _meeting.admitted;
    final otherName = widget.host ? _meeting.patientName : _meeting.doctorName;

    return Scaffold(
      appBar: AppBar(
        title: Text(inRoom ? l10n.inTheMeeting : l10n.waitingRoom),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.roomNumber} ${_meeting.roomCode}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(localizeMessage(l10n, _error!), style: TextStyle(color: scheme.error)),
            if (ended)
              Text(l10n.meetingEnded)
            else if (!inRoom)
              Text(l10n.waitingForDoctor)
            else ...[
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _PersonTile(name: otherName, filled: _meeting.admitted)),
                    const SizedBox(width: 12),
                    Expanded(child: _PersonTile(name: widget.selfName, filled: true)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.meetingWith(otherName)),
              const SizedBox(height: 8),
              Text(l10n.videoNotSent),
            ],
            if (widget.host && _meeting.waiting && !_meeting.admitted && !ended) ...[
              const SizedBox(height: 16),
              Text(l10n.patientWaiting(_meeting.patientName)),
              const SizedBox(height: 8),
              FilledButton(onPressed: _admit, child: Text(l10n.letThemIn)),
            ],
            if (widget.host && !ended) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _end, child: Text(l10n.endMeeting)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.name, required this.filled});

  final String name;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filled ? Icons.person : Icons.hourglass_empty,
                size: 40,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(height: 8),
              Text(name, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
