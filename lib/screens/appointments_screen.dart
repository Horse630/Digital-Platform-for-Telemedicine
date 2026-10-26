import 'package:flutter/material.dart';

import '../widgets/status_placeholder.dart';

/// Appointment tab.
///
/// Booking rules and MongoDB records are a later phase. This screen only
/// tells the user that nothing is scheduled.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatusPlaceholder(
      icon: Icons.event_busy_outlined,
      title: 'No appointments yet',
      message: 'Booking will be stored in MongoDB in a later phase.',
    );
  }
}
