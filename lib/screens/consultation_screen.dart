import 'package:flutter/material.dart';

import '../widgets/status_placeholder.dart';

/// Video-visit tab.
///
/// The video SDK is planned for a later phase. This screen is the place
/// that call will open from.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatusPlaceholder(
      icon: Icons.videocam_off_outlined,
      title: 'Video visits are not available yet',
      message: 'You can book a time now. The video call will open here when it is ready.',
    );
  }
}
