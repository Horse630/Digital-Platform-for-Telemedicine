import 'package:flutter/material.dart';

/// Tabs in the signed-in shell, listed in navigation order.
enum AppDestination {
  home('Home', Icons.home_outlined, Icons.home),
  appointments(
    'Appointments',
    Icons.calendar_month_outlined,
    Icons.calendar_month,
  ),
  consultation('Consultation', Icons.video_chat_outlined, Icons.video_chat),
  profile('Profile', Icons.person_outline, Icons.person);

  const AppDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
