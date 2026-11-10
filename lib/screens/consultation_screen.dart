import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/meeting_api.dart';
import '../widgets/content_frame.dart';
import 'meeting_room_screen.dart';

/// Meeting lobby opened from Home and from the Meetings tab.
///
/// A doctor sees today's booked visits and a room number that stays the same
/// until they change it. A patient sees meetings the doctor has opened, and
/// only from 10 minutes before the visit.
class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.active,
  });

  final SignedInUser user;
  final AuthService authService;
  final bool active;

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _roomCode = TextEditingController();
  List<MeetingRecord> _meetings = [];
  String? _selectedId;
  String? _error;
  bool _loading = false;
  bool _savingRoom = false;

  MeetingApi get _api => MeetingApi(
    authService: widget.authService,
    token: widget.user.token,
  );

  MeetingRecord? get _selectedMeeting {
    for (final meeting in _meetings) {
      if (meeting.appointmentId == _selectedId) {
        return meeting;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant ConsultationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final opened = widget.active && !oldWidget.active;
    final tokenChanged = oldWidget.user.token != widget.user.token;
    if (opened || (widget.active && tokenChanged)) {
      _load();
    }
  }

  @override
  void dispose() {
    _roomCode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.user.role == 'admin') {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = widget.user.role == 'doctor'
          ? await _api.listToday(DateTime.now())
          : await _api.listOpen();
      if (!mounted) {
        return;
      }
      if (list.roomCode.isNotEmpty) {
        _roomCode.text = list.roomCode;
      }
      final stillThere = list.meetings.any((row) => row.appointmentId == _selectedId);
      setState(() {
        _meetings = list.meetings;
        if (!stillThere) {
          _selectedId = list.meetings.isEmpty ? null : list.meetings.first.appointmentId;
        }
        _loading = false;
      });
    } on MeetingException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _saveRoom() async {
    setState(() => _savingRoom = true);
    try {
      final code = await _api.saveRoom(_roomCode.text);
      if (!mounted) {
        return;
      }
      setState(() => _roomCode.text = code);
    } on MeetingException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _savingRoom = false);
      }
    }
  }

  Future<void> _host(MeetingRecord meeting) async {
    try {
      final opened = await _api.host(meeting.appointmentId);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MeetingRoomScreen(
            authService: widget.authService,
            token: widget.user.token,
            meeting: opened,
            host: true,
            selfName: widget.user.fullName,
          ),
        ),
      );
      await _load();
    } on MeetingException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _join() async {
    final selected = _meetings.where((row) => row.appointmentId == _selectedId);
    if (selected.isEmpty) {
      return;
    }
    try {
      final opened = await _api.join(selected.first.appointmentId);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MeetingRoomScreen(
            authService: widget.authService,
            token: widget.user.token,
            meeting: opened,
            host: false,
            selfName: widget.user.fullName,
          ),
        ),
      );
      await _load();
    } on MeetingException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (widget.user.role == 'admin') {
      return ContentFrame(
        child: Center(child: Text(l10n.meetingsRoleHint, textAlign: TextAlign.center)),
      );
    }
    return ContentFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            widget.user.role == 'doctor' ? l10n.todayMeetings : l10n.joinMeetingTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (widget.user.role == 'patient')
            Text(l10n.joinWindowHint),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              localizeMessage(l10n, _error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.user.role == 'doctor') ...[
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('meetingRoomField'),
              controller: _roomCode,
              decoration: InputDecoration(labelText: l10n.roomNumber),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _savingRoom ? null : _saveRoom,
                child: Text(l10n.saveRoomNumber),
              ),
            ),
            const SizedBox(height: 16),
            if (_meetings.isEmpty)
              Text(l10n.noMeetingsToday)
            else
              for (final meeting in _meetings)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(meeting.patientName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(_clock(meeting.scheduledAt)),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => _host(meeting),
                          child: Text(l10n.hostMeeting),
                        ),
                      ],
                    ),
                  ),
                ),
          ] else ...[
            const SizedBox(height: 16),
            if (_meetings.isEmpty)
              Text(l10n.noOpenMeetings)
            else ...[
              DropdownButtonFormField<String>(
                key: const Key('openMeetingMenu'),
                initialValue: _selectedId,
                decoration: InputDecoration(labelText: l10n.selectMeeting),
                items: [
                  for (final meeting in _meetings)
                    DropdownMenuItem(
                      value: meeting.appointmentId,
                      child: Text('${_clock(meeting.scheduledAt)} · ${meeting.doctorName}'),
                    ),
                ],
                onChanged: (value) => setState(() => _selectedId = value),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('joinMeetingButton'),
                onPressed: _selectedMeeting?.canEnter == true ? _join : null,
                child: Text(l10n.joinMeeting),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

String _clock(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
