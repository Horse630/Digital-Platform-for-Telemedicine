import 'package:flutter/material.dart';

import '../language/ui_text.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
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
        title: context.l10n.appointmentsUnavailable,
        message: localizeMessage(context.l10n, _error!),
      );
    }

    final role = widget.user.role;
    if (role == 'doctor') {
      return _DoctorSchedule(
        appointments: _appointments,
        onAdd: _addSlot,
        onCancel: _cancel,
        onRemove: _remove,
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
        onRemove: _remove,
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
        SnackBar(content: Text(context.l10n.chooseFutureTime)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, error.message))),
      );
      return false;
    }
  }

  Future<void> _cancel(AppointmentRecord appointment) async {
    final l10n = context.l10n;
    final confirmed = await _confirm(
      title: l10n.confirmCancelTitle,
      message: _cancelWarning(l10n, appointment),
      confirmLabel: widget.user.role == 'patient'
          ? l10n.cancelBooking
          : l10n.cancelSlot,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _run(_api.cancel(appointment.id));
  }

  String _cancelWarning(AppLocalizations l10n, AppointmentRecord appointment) {
    if (widget.user.role == 'patient') {
      return l10n.confirmCancelBookingMessage;
    }
    if (appointment.status == 'available') {
      return l10n.confirmCancelSlotMessage;
    }
    return l10n.confirmCancelVisitMessage;
  }

  Future<void> _remove(AppointmentRecord appointment) async {
    final l10n = context.l10n;
    final confirmed = await _confirm(
      title: l10n.confirmRemoveTitle,
      message: l10n.confirmRemoveMessage,
      confirmLabel: l10n.remove,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _run(_api.remove(appointment.id));
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(message),
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
                  child: Text(dialogContext.l10n.keep),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        );
      },
    );
    return answer ?? false;
  }
}

class _DoctorSchedule extends StatelessWidget {
  const _DoctorSchedule({
    required this.appointments,
    required this.onAdd,
    required this.onCancel,
    required this.onRemove,
  });

  final List<AppointmentRecord> appointments;
  final VoidCallback onAdd;
  final Future<void> Function(AppointmentRecord appointment) onCancel;
  final Future<void> Function(AppointmentRecord appointment) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (appointments.isEmpty) {
      return _Message(
        icon: Icons.event_busy_outlined,
        title: l10n.noAppointment,
        message: l10n.noAppointmentYet,
        actionKey: const Key('addTimeSlot'),
        actionLabel: l10n.makeAppointment,
        onAction: onAdd,
      );
    }

    return _AppointmentBrowser(
      appointments: appointments,
      action: FilledButton.icon(
        key: const Key('addTimeSlot'),
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: Text(l10n.makeAppointment),
      ),
      cardBuilder: (appointment) {
        final open = appointment.status == 'available';
        final booked = appointment.status == 'scheduled';
        return _AppointmentCard(
          appointment: appointment,
          detail: open
              ? l10n.openForPatients
              : l10n.patientLine(appointment.patientName ?? l10n.unknown),
          actionLabel: open || booked ? l10n.cancelSlot : null,
          onAction: open || booked ? () => onCancel(appointment) : null,
          onRemove: appointment.status == 'cancelled'
              ? () => onRemove(appointment)
              : null,
        );
      },
    );
  }
}

class _MyAppointments extends StatelessWidget {
  const _MyAppointments({
    required this.appointments,
    required this.onOpenBooking,
    required this.onCancel,
    required this.onRemove,
  });

  final List<AppointmentRecord> appointments;
  final VoidCallback onOpenBooking;
  final Future<void> Function(AppointmentRecord appointment) onCancel;
  final Future<void> Function(AppointmentRecord appointment) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (appointments.isEmpty) {
      return _Message(
        icon: Icons.event_busy_outlined,
        title: l10n.noAppointment,
        message: l10n.noAppointmentYet,
        actionKey: const Key('openBookingButton'),
        actionLabel: l10n.bookAppointment,
        onAction: onOpenBooking,
      );
    }

    return _AppointmentBrowser(
      appointments: appointments,
      action: FilledButton(
        key: const Key('openBookingButton'),
        onPressed: onOpenBooking,
        child: Text(l10n.bookAppointment),
      ),
      cardBuilder: (appointment) {
        return _AppointmentCard(
          appointment: appointment,
          detail: appointment.reason.isEmpty
              ? _doctorDetail(l10n, appointment)
              : appointment.reason,
          actionLabel: appointment.status == 'scheduled' ? l10n.cancelBooking : null,
          onAction: appointment.status == 'scheduled'
              ? () => onCancel(appointment)
              : null,
          onRemove: appointment.status == 'cancelled'
              ? () => onRemove(appointment)
              : null,
        );
      },
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
    final l10n = context.l10n;
    final query = AppointmentQuery(
      doctorName: _doctorName.text,
      doctorType: _doctorType.isEmpty ? null : _doctorType,
      sort: _sort,
    );
    final open = filterAppointments(widget.appointments, query);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookAppointment)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('doctorNameSearch'),
            controller: _doctorName,
            decoration: InputDecoration(
              hintText: l10n.doctorName,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _FilterMenu<String>(
            fieldKey: const Key('doctorTypeFilter'),
            label: l10n.doctorTypeLabel,
            value: _doctorType,
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.allTypes)),
              for (final type in doctorTypes)
                DropdownMenuItem(
                  value: type,
                  child: Text(localizedDoctorType(l10n, type)),
                ),
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
            label: l10n.sort,
            value: _sort,
            items: [
              DropdownMenuItem(
                value: AppointmentSort.soonest,
                child: Text(l10n.soonest),
              ),
              DropdownMenuItem(
                value: AppointmentSort.latest,
                child: Text(l10n.latest),
              ),
              DropdownMenuItem(
                value: AppointmentSort.nameAscending,
                child: Text(l10n.nameAz),
              ),
              DropdownMenuItem(
                value: AppointmentSort.nameDescending,
                child: Text(l10n.nameZa),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sort = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(l10n.openTimes, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (open.isEmpty)
            _InlineNote(
              query.isFiltering
                  ? l10n.noOpenTimesMatch
                  : l10n.noOpenTimes,
            ),
          for (final appointment in open) ...[
            _AppointmentCard(
              appointment: appointment,
              detail: _doctorDetail(l10n, appointment),
              actionLabel: l10n.book,
              onAction: () => widget.onBook(appointment),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

String _doctorDetail(AppLocalizations l10n, AppointmentRecord appointment) {
  if (appointment.doctorSpecialty.isEmpty) {
    return appointment.doctorName;
  }
  return '${appointment.doctorName} · ${localizedSpecialtyLine(l10n, appointment.doctorSpecialty)}';
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
    final l10n = context.l10n;
    if (appointments.isEmpty) {
      return _Message(
        icon: Icons.event_busy_outlined,
        title: l10n.noAppointmentsYet,
        message: l10n.doctorsHaveNotPublished,
      );
    }
    return _AppointmentBrowser(
      appointments: appointments,
      cardBuilder: (appointment) {
        final person = appointment.patientName ?? l10n.noPatientYet;
        return _AppointmentCard(
          appointment: appointment,
          detail: '${appointment.doctorName} · $person',
        );
      },
    );
  }
}

enum _ScheduleView { calendar, list }

class _AppointmentBrowser extends StatefulWidget {
  const _AppointmentBrowser({
    required this.appointments,
    required this.cardBuilder,
    this.action,
  });

  final List<AppointmentRecord> appointments;
  final Widget Function(AppointmentRecord appointment) cardBuilder;
  final Widget? action;

  @override
  State<_AppointmentBrowser> createState() => _AppointmentBrowserState();
}

class _AppointmentBrowserState extends State<_AppointmentBrowser> {
  _ScheduleView _view = _ScheduleView.calendar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.action != null) ...[
                widget.action!,
                const SizedBox(height: 12),
              ],
              SegmentedButton<_ScheduleView>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _ScheduleView.calendar,
                    label: Text(context.l10n.calendar),
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                  ButtonSegment(
                    value: _ScheduleView.list,
                    label: Text(context.l10n.list),
                    icon: const Icon(Icons.view_list_outlined),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (selected) {
                  setState(() => _view = selected.first);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _view == _ScheduleView.calendar
              ? _CalendarSchedule(
                  appointments: widget.appointments,
                  cardBuilder: widget.cardBuilder,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.appointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return widget.cardBuilder(widget.appointments[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _CalendarSchedule extends StatefulWidget {
  const _CalendarSchedule({
    required this.appointments,
    required this.cardBuilder,
  });

  final List<AppointmentRecord> appointments;
  final Widget Function(AppointmentRecord appointment) cardBuilder;

  @override
  State<_CalendarSchedule> createState() => _CalendarScheduleState();
}

class _CalendarScheduleState extends State<_CalendarSchedule> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final first = _earliestDay(widget.appointments);
    _selected = first;
    _month = DateTime(first.year, first.month);
  }

  @override
  Widget build(BuildContext context) {
    final marked = {
      for (final item in widget.appointments) _calendarDay(item.scheduledAt),
    };
    final onDay = [
      for (final item in widget.appointments)
        if (_calendarDay(item.scheduledAt) == _selected) item,
    ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final scheme = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final l10n = context.l10n;
    final weekdays = localizations.narrowWeekdays;
    final mondayFirst = [...weekdays.sublist(1), weekdays.first];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.previousMonth,
              onPressed: () {
                setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                localizations.formatMonthYear(_month),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.nextMonth,
              onPressed: () {
                setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final label in mondayFirst)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        _MonthDays(
          month: _month,
          selected: _selected,
          marked: marked,
          onSelect: (day) => setState(() => _selected = day),
        ),
        const SizedBox(height: 16),
        Text(
          localizations.formatMediumDate(_selected),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (onDay.isEmpty)
          Text(
            l10n.noAppointmentOnDay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          )
        else
          for (final appointment in onDay) ...[
            widget.cardBuilder(appointment),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MonthDays extends StatelessWidget {
  const _MonthDays({
    required this.month,
    required this.selected,
    required this.marked,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Set<DateTime> marked;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final first = DateTime(month.year, month.month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final total = leading + days;
    final cells = total + (7 - total % 7) % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leading + 1;
        if (dayNumber < 1 || dayNumber > days) {
          return const SizedBox.shrink();
        }
        final day = DateTime(month.year, month.month, dayNumber);
        final isSelected = day == selected;
        final hasAppointment = marked.contains(day);
        return InkWell(
          onTap: () => onSelect(day),
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isSelected ? scheme.primary : null,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? scheme.onPrimary : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 4,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: hasAppointment ? scheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

DateTime _calendarDay(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}

DateTime _earliestDay(List<AppointmentRecord> appointments) {
  final sorted = [...appointments]
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return _calendarDay(sorted.first.scheduledAt);
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.detail,
    this.actionLabel,
    this.onAction,
    this.onRemove,
  });

  final AppointmentRecord appointment;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRemove;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '$date, $time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: context.l10n.remove,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(detail),
            const SizedBox(height: 4),
            Text(
              localizedStatus(context.l10n, appointment.status),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.bookThisTime),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 200,
        decoration: InputDecoration(
          labelText: l10n.reasonForVisit,
          errorText: _error == null ? null : localizeMessage(l10n, _error!),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
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
          child: Text(l10n.book),
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
