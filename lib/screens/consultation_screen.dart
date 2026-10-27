import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../widgets/status_placeholder.dart';

/// Video-visit tab.
///
/// The video SDK is planned for a later phase. This screen is the place
/// that call will open from.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StatusPlaceholder(
      icon: Icons.videocam_off_outlined,
      title: l10n.videoNotAvailable,
      message: l10n.videoNotAvailableMessage,
    );
  }
}
