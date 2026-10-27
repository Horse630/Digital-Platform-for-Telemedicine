import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../navigation/app_destination.dart';
import '../services/appointment_api.dart';
import '../services/appointment_filter.dart';
import '../services/auth_service.dart';
import '../services/discussion_api.dart';
import '../widgets/content_frame.dart';
import 'delivery_map_screen.dart';
import 'discussions_screen.dart';
import 'sick_leave_screen.dart';

/// Home dashboard.
///
/// The tiles follow the core functions and sub-functions in the progress
/// report. The next-appointment card reads the signed-in person's bookings.
/// Appointments and Consultation open their tabs. Discussion opens the
/// public question board. Sick leave opens certificates. Medication delivery
/// opens a map of Hong Kong. Every other tile only explains that the module
/// does not save data yet.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.active,
    required this.onOpen,
  });

  final SignedInUser user;
  final AuthService authService;
  final bool active;
  final ValueChanged<AppDestination> onOpen;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppointmentApi _api;
  AppointmentRecord? _next;
  int _discussionUnread = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _api = _apiFor(widget.user.token);
    _load();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tokenChanged = oldWidget.user.token != widget.user.token;
    final openedAgain = widget.active && !oldWidget.active;
    if (tokenChanged) {
      _api = _apiFor(widget.user.token);
    }
    if (tokenChanged || openedAgain) {
      _load();
    }
  }

  AppointmentApi _apiFor(String token) {
    return AppointmentApi(authService: widget.authService, token: token);
  }

  Future<void> _load() async {
    try {
      final appointments = await _api.list();
      if (!mounted) {
        return;
      }
      setState(() {
        _next = nextScheduledAppointment(appointments);
        _loaded = true;
      });
    } on AppointmentException {
      if (!mounted) {
        return;
      }
      setState(() {
        _next = null;
        _loaded = true;
      });
    }
    try {
      final topics = await DiscussionApi(
        authService: widget.authService,
        token: widget.user.token,
      ).list();
      if (!mounted) {
        return;
      }
      final unread = topics.fold<int>(
        0,
        (total, topic) => total + topic.unreadCount,
      );
      setState(() => _discussionUnread = unread);
    } on DiscussionException {
      if (mounted) {
        setState(() => _discussionUnread = 0);
      }
    }
  }

  Future<void> _openModule(BuildContext context, _Module module) async {
    if (module.opensDelivery) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const DeliveryMapScreen(),
        ),
      );
      return;
    }
    if (module.opensSickLeave) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SickLeaveScreen(
            authService: widget.authService,
            user: widget.user,
          ),
        ),
      );
      return;
    }
    if (module.opensDiscussion) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DiscussionsScreen(
            authService: widget.authService,
            user: widget.user,
          ),
        ),
      );
      if (mounted) {
        await _load();
      }
      return;
    }
    final destination = module.destination;
    if (destination != null) {
      widget.onOpen(destination);
      return;
    }
    _showPendingModule(context, module.title);
  }

  static List<_Module> _coreModules(AppLocalizations l10n) {
    return [
      _Module(
        icon: Icons.event_available_outlined,
        title: l10n.navAppointments,
        subtitle: l10n.appointmentsSubtitle,
        destination: AppDestination.appointments,
      ),
      _Module(
        icon: Icons.video_camera_front_outlined,
        title: l10n.consultationTitle,
        subtitle: l10n.consultationSubtitle,
        destination: AppDestination.consultation,
      ),
      _Module(
        icon: Icons.description_outlined,
        title: l10n.sickLeave,
        subtitle: l10n.sickLeaveSubtitle,
        opensSickLeave: true,
      ),
      _Module(
        icon: Icons.payments_outlined,
        title: l10n.payment,
        subtitle: l10n.paymentSubtitle,
      ),
      _Module(
        icon: Icons.local_shipping_outlined,
        title: l10n.medicationDelivery,
        subtitle: l10n.medicationDeliverySubtitle,
        opensDelivery: true,
      ),
    ];
  }

  static List<_Module> _otherModules(AppLocalizations l10n) {
    return [
      _Module(
        icon: Icons.smart_toy_outlined,
        title: l10n.aiChatbot,
        subtitle: l10n.aiChatbotSubtitle,
      ),
      _Module(
        icon: Icons.forum_outlined,
        title: l10n.discussion,
        subtitle: l10n.discussionSubtitle,
        opensDiscussion: true,
      ),
      _Module(
        icon: Icons.monitor_heart_outlined,
        title: l10n.iotHealth,
        subtitle: l10n.iotHealthSubtitle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return ContentFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.welcomeBack(widget.user.fullName),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              localizedDashboard(l10n, widget.user.role),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _SectionHeader(l10n.overview),
            LayoutBuilder(
              builder: (context, constraints) {
                final nextAppointment = _NextAppointmentCard(
                  appointment: _loaded ? _next : null,
                  role: widget.user.role,
                  onTap: () => widget.onOpen(AppDestination.appointments),
                );
                final delivery = _SummaryCard(
                  icon: Icons.local_shipping_outlined,
                  label: l10n.medicationDelivery,
                  value: l10n.noActiveOrder,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DeliveryMapScreen(),
                    ),
                  ),
                );

                if (constraints.maxWidth < 560) {
                  return Column(
                    children: [
                      nextAppointment,
                      const SizedBox(height: 12),
                      delivery,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: nextAppointment),
                    const SizedBox(width: 12),
                    Expanded(child: delivery),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionHeader(l10n.coreServices),
            _ModuleGrid(
              modules: _coreModules(l10n),
              onOpen: (module) => _openModule(context, module),
            ),
            const SizedBox(height: 24),
            _SectionHeader(l10n.otherServices),
            _ModuleGrid(
              modules: _otherModules(l10n),
              discussionUnread: _discussionUnread,
              onOpen: (module) => _openModule(context, module),
            ),
          ],
        ),
      ),
    );
  }
}

class _Module {
  const _Module({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.destination,
    this.opensDiscussion = false,
    this.opensSickLeave = false,
    this.opensDelivery = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AppDestination? destination;
  final bool opensDiscussion;
  final bool opensSickLeave;
  final bool opensDelivery;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    required this.appointment,
    required this.role,
    required this.onTap,
  });

  final AppointmentRecord? appointment;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appointment = this.appointment;
    final l10n = context.l10n;
    final value = appointment == null
        ? l10n.notScheduled
        : _when(context, appointment.scheduledAt.toLocal());
    final detail = appointment == null ? null : _who(l10n, appointment, role);
    return _SummaryCard(
      icon: Icons.event_outlined,
      label: l10n.nextAppointment,
      value: value,
      detail: detail,
      onTap: onTap,
    );
  }

  String _when(BuildContext context, DateTime local) {
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = TimeOfDay.fromDateTime(local).format(context);
    return '$date, $time';
  }

  String _who(AppLocalizations l10n, AppointmentRecord appointment, String role) {
    if (role == 'doctor') {
      return l10n.patientLine(appointment.patientName ?? l10n.unknown);
    }
    if (appointment.doctorSpecialty.isEmpty) {
      return appointment.doctorName;
    }
    return '${appointment.doctorName} · ${localizedSpecialtyLine(l10n, appointment.doctorSpecialty)}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: Theme.of(context).textTheme.titleMedium),
                    if (detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail!,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({
    required this.modules,
    required this.onOpen,
    this.discussionUnread = 0,
  });

  final List<_Module> modules;
  final ValueChanged<_Module> onOpen;
  final int discussionUnread;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 164,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            return _ServiceTile(
              icon: module.icon,
              title: module.title,
              subtitle: module.subtitle,
              badge: module.opensDiscussion ? discussionUnread : 0,
              onTap: () => onOpen(module),
            );
          },
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: badge > 0
                      ? Badge.count(
                          count: badge,
                          backgroundColor: const Color(0xFFE53935),
                          textColor: Colors.white,
                          child: Icon(icon, color: scheme.onPrimaryContainer),
                        )
                      : Icon(icon, color: scheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPendingModule(BuildContext context, String title) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(AppLocalizations.of(dialogContext).serviceUnavailable),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext).close),
          ),
        ],
      );
    },
  );
}
