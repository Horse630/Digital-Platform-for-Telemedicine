import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shows the saved profile photo, or a person icon when there is none.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.avatarBase64, this.radius = 40});

  final String avatarBase64;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bytes = _bytes(avatarBase64);
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      backgroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes == null
          ? Icon(Icons.person, size: radius, color: scheme.onPrimaryContainer)
          : null,
    );
  }
}

Uint8List? _bytes(String value) {
  if (value.isEmpty) {
    return null;
  }
  try {
    final decoded = base64Decode(value);
    if (decoded.isEmpty) {
      return null;
    }
    return decoded;
  } catch (_) {
    return null;
  }
}
