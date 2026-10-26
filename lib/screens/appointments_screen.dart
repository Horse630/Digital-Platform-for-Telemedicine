import 'package:flutter/material.dart';

import '../services/appointment_api.dart';
import '../services/auth_service.dart';

/// Appointment tab.
///
/// A doctor publishes open times. A patient books one of those times.
/// An admin can read every row and cannot change them.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  final SignedInUser user;
  final AuthService authService;

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final AppointmentApi _api = AppointmentApi(
    authService: widget.authService,
    token: widget.user.token,
  );

  List<AppointmentRecord> _appointments = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appointments = await _api.list();
      if (!mounted) {
        return;
      }
      setState(() => _appointments = appointments);
    } on AppointmentException catch (error) {
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

  Future<void> _run(Future<void> action) async {
    try {
      await action;
      await _load();
    } on AppointmentException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _Message(
        icon: Icons.cloud_off_outlined,
        title: 'Appointments unavailable',
        message: _error!,
      );
    }

    final role = widget.user.role;
    if (role == 'doctor') {
      return _DoctorSchedule(
        appointments: _appointments,
        onAdd: _addSlot,
        onCancel: _cancel,
      );
    }
    if (role == 'patient') {
      return _PatientSchedule(
        appointments: _appointments,
        onBook: _book,
        onCancel: _cancel,
      );
    }
    return _AdminSchedule(appointments: _appointments);
  }

  Future<void> _addSlot() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !mounted) {
      return;
    }
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!scheduledAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a time in the future.')),
      );
      return;
    }
    await _run(_api.addSlot(scheduledAt));
  }

  Future<void> _book(AppointmentRecord appointment) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ReasonDialog(),
    );
    if (reason == null || !mounted) {
      return;
    }
    await _run(_api.book(appointment.id, reason));
  }

  Future<void> _cancel(AppointmentRecord appointment) {
    return _run(_api.cancel(appointment.id));
  }
}

class _DoctorSchedule extends StatelessWidget {
  const _DoctorSchedule({
    required this.appointments,
    required this.onAdd,
    required this.onCancel,
  });

  final List<AppointmentRecord> appointments;
  final VoidCallback onAdd;
  final Future<void> Function(AppointmentRecord appointment) onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('addTimeSlot'),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add time slot'),
            ),
          ),
        ),
        Expanded(
          child: appointments.isEmpty
              ? const _Message(
                  icon: Icons.event_available_outlined,
                  title: 'No time slots yet',
                  message: 'Add a time. Patients can then book it.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final open = appointment.status == 'available';
                    final booked = appointment.status == 'scheduled';
                    return _AppointmentCard(
                      appointment: appointment,
                      detail: open
                          ? 'Open for patients'
                          : 'Patient: ${appointment.patientName ?? 'Unknown'}',
                      actionLabel: open || booked ? 'Cancel slot' : null,
                      onAction: open || booked
                          ? () => onCancel(appointment)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PatientSchedule extends StatelessWidget {
  const _PatientSchedule({
    required this.appointments,
    required this.onBook,
    required this.onCancel,
  });

  final List<AppointmentRecord> appointments;
  final Future<void> Function(AppointmentRecord appointment) onBook;
  final Future<void> Function(AppointmentRecord appointment) onCancel;

  @override
  Widget build(BuildContext context) {
    final open = appointments
        .where((item) => item.status == 'available')
        .toList();
    final mine = appointments
        .where((item) => item.status != 'available')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Open times', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (open.isEmpty)
          const _InlineNote(
            'No open time slots. A doctor has not published a time yet.',
          ),
        for (final appointment in open) ...[
          _AppointmentCard(
            appointment: appointment,
            detail: _doctorDetail(appointment),
            actionLabel: 'Book',
            onAction: () => onBook(appointment),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        Text('My appointments', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (mine.isEmpty) const _InlineNote('You have no appointments.'),
        for (final appointment in mine) ...[
          _AppointmentCard(
            appointment: appointment,
            detail: appointment.reason.isEmpty
                ? _doctorDetail(appointment)
                : appointment.reason,
            actionLabel: appointment.status == 'scheduled'
                ? 'Cancel booking'
                : null,
            onAction: appointment.status == 'scheduled'
                ? () => onCancel(appointment)
                : null,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  String _doctorDetail(AppointmentRecord appointment) {
    if (appointment.doctorSpecialty.isEmpty) {
      return appointment.doctorName;
    }
    return '${appointment.doctorName} · ${appointment.doctorSpecialty}';
  }
}

class _AdminSchedule extends StatelessWidget {
  const _AdminSchedule({required this.appointments});

  final List<AppointmentRecord> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const _Message(
        icon: Icons.event_busy_outlined,
        title: 'No appointments yet',
        message: 'Doctors have not published a time slot.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final person = appointment.patientName ?? 'No patient yet';
        return _AppointmentCard(
          appointment: appointment,
          detail: '${appointment.doctorName} · $person',
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final AppointmentRecord appointment;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final local = appointment.scheduledAt.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = TimeOfDay.fromDateTime(local).format(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$date, $time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(detail),
            const SizedBox(height: 4),
            Text(
              appointment.status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog();

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book this time'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 200,
        decoration: InputDecoration(
          labelText: 'Reason for the visit',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = 'Enter a short reason for the visit.');
              return;
            }
            Navigator.pop(context, reason);
          },
          child: const Text('Book'),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
