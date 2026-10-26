import 'package:flutter/material.dart';

/// Caps page width and keeps the child as tall as the body.
///
/// Phone layouts stay full width. Wider windows keep a readable column
/// in the center.
class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child, this.maxWidth = 960});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : null;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, height: height, child: child),
        );
      },
    );
  }
}
