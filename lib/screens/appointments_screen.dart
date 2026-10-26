import 'package:flutter/material.dart';

import '../services/appointment_api.dart';
import '../services/appointment_filter.dart';
import '../services/auth_service.dart';
import '../services/doctor_types.dart';

/// Appointment tab.
///
/// A doctor publishes open times. A patient sees only their own bookings
/// here, and opens a separate page to choose an open time.
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
  // Replaced when settings issues a new token after a username change.
  late AppointmentApi _api;

  List<AppointmentRecord> _appointments = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = _apiFor(widget.user.token);
    _load();
  }

  @override
  void didUpdateWidget(covariant AppointmentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.token != widget.user.token) {
      _api = _apiFor(widget.user.token);
    }
  }

  AppointmentApi _apiFor(String token) {
    return AppointmentApi(authService: widget.authService, token: token);
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
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
      final mine = filterAppointments(
        _appointments.where((item) => item.status != 'available').toList(),
        const AppointmentQuery(),
      );
      return _MyAppointments(
        appointments: mine,
        onOpenBooking: _openBooking,
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

  Future<void> _openBooking() {
    final open = _appointments
        .where((item) => item.status == 'available')
        .toList();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => _OpenTimesPage(
          appointments: open,
          onBook: (appointment) async {
            final booked = await _book(appointment);
            if (booked && routeContext.mounted) {
              Navigator.of(routeContext).pop();
            }
          },
        ),
      ),
    );
  }

  Future<bool> _book(AppointmentRecord appointment) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ReasonDialog(),
    );
    if (reason == null || !mounted) {
      return false;
    }
    try {
      await _api.book(appointment.id, reason);
      await _load(showSpinner: false);
      return true;
    } on AppointmentException catch (error) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
      return false;
    }
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
    if (appointments.isEmpty) {
      return _Message(
        icon: Icons.event_busy_outlined,
        title: 'No appointment',
        message: 'You have no appointment yet.',
        actionKey: const Key('addTimeSlot'),
        actionLabel: 'Make an appointment',
        onAction: onAdd,
      );
    }

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
              label: const Text('Make an appointment'),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
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
                onAction: open || booked ? () => onCancel(appointment) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyAppointments extends StatelessWidget {
  const _MyAppointments({
    required this.appointments,
    required this.onOpenBooking,
    required this.onCancel,
  });

  final List<AppointmentRecord> appointments;
  final VoidCallback onOpenBooking;
  final Future<void> Function(AppointmentRecord appointment) onCancel;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _Message(
        icon: Icons.event_busy_outlined,
        title: 'No appointment',
        message: 'You have no appointment yet.',
        actionKey: const Key('openBookingButton'),
        actionLabel: 'Book an appointment',
        onAction: onOpenBooking,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const Key('openBookingButton'),
            onPressed: onOpenBooking,
            child: const Text('Book an appointment'),
          ),
        ),
        const SizedBox(height: 12),
        for (final appointment in appointments) ...[
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
}

class _OpenTimesPage extends StatefulWidget {
  const _OpenTimesPage({required this.appointments, required this.onBook});

  final List<AppointmentRecord> appointments;
  final Future<void> Function(AppointmentRecord appointment) onBook;

  @override
  State<_OpenTimesPage> createState() => _OpenTimesPageState();
}

class _OpenTimesPageState extends State<_OpenTimesPage> {
  final _doctorName = TextEditingController();
  String _doctorType = '';
  AppointmentSort _sort = AppointmentSort.soonest;

  @override
  void dispose() {
    _doctorName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = AppointmentQuery(
      doctorName: _doctorName.text,
      doctorType: _doctorType.isEmpty ? null : _doctorType,
      sort: _sort,
    );
    final open = filterAppointments(widget.appointments, query);

    return Scaffold(
      appBar: AppBar(title: const Text('Book an appointment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('doctorNameSearch'),
            controller: _doctorName,
            decoration: const InputDecoration(
              hintText: 'Doctor name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _FilterMenu<String>(
            fieldKey: const Key('doctorTypeFilter'),
            label: 'Doctor type',
            value: _doctorType,
            items: [
              const DropdownMenuItem(value: '', child: Text('All types')),
              for (final type in doctorTypes)
                DropdownMenuItem(value: type, child: Text(type)),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _doctorType = value);
              }
            },
          ),
          const SizedBox(height: 12),
          _FilterMenu<AppointmentSort>(
            fieldKey: const Key('appointmentSort'),
            label: 'Sort',
            value: _sort,
            items: const [
              DropdownMenuItem(
                value: AppointmentSort.soonest,
                child: Text('Soonest'),
              ),
              DropdownMenuItem(
                value: AppointmentSort.latest,
                child: Text('Latest'),
              ),
              DropdownMenuItem(
                value: AppointmentSort.nameAscending,
                child: Text('Name A–Z'),
              ),
              DropdownMenuItem(
                value: AppointmentSort.nameDescending,
                child: Text('Name Z–A'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sort = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Open times', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (open.isEmpty)
            _InlineNote(
              query.isFiltering
                  ? 'No open times match this search.'
                  : 'No open time slots. A doctor has not published a time yet.',
            ),
          for (final appointment in open) ...[
            _AppointmentCard(
              appointment: appointment,
              detail: _doctorDetail(appointment),
              actionLabel: 'Book',
              onAction: () => widget.onBook(appointment),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

String _doctorDetail(AppointmentRecord appointment) {
  if (appointment.doctorSpecialty.isEmpty) {
    return appointment.doctorName;
  }
  return '${appointment.doctorName} · ${appointment.doctorSpecialty}';
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: fieldKey,
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
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
    this.actionLabel,
    this.onAction,
    this.actionKey,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;

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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                key: actionKey,
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
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
