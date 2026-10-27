import 'package:flutter/material.dart';

import '../language/app_localizations.dart';

/// Tabs in the signed-in shell, listed in navigation order.
enum AppDestination {
  home(Icons.home_outlined, Icons.home),
  appointments(Icons.calendar_month_outlined, Icons.calendar_month),
  messages(Icons.chat_bubble_outline, Icons.chat_bubble),
  consultation(Icons.video_chat_outlined, Icons.video_chat),
  profile(Icons.person_outline, Icons.person);

  const AppDestination(this.icon, this.selectedIcon);

  final IconData icon;
  final IconData selectedIcon;

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case AppDestination.home:
        return l10n.navHome;
      case AppDestination.appointments:
        return l10n.navAppointments;
      case AppDestination.messages:
        return l10n.navMessages;
      case AppDestination.consultation:
        return l10n.navConsultation;
      case AppDestination.profile:
        return l10n.navProfile;
    }
  }
}
