import 'package:flutter/material.dart';

import '../language/ui_text.dart';

/// Fixed answers about how to use the app.
///
/// This screen does not call the HKBU GenAI API.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.guideTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.guideHint),
          const SizedBox(height: 16),
          ExpansionTile(
            title: Text(l10n.navAppointments),
            children: [
              ListTile(title: Text(l10n.guideAppointments)),
            ],
          ),
          ExpansionTile(
            title: Text(l10n.consultationTitle),
            children: [
              ListTile(title: Text(l10n.guideMeetings)),
            ],
          ),
          ExpansionTile(
            title: Text(l10n.medicationDelivery),
            children: [
              ListTile(title: Text(l10n.guideDelivery)),
            ],
          ),
        ],
      ),
    );
  }
}
