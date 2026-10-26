import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:digital_platform_for_telemedicine/services/avatar_image.dart';

void main() {
  test('accepts a small PNG and rejects other files', () {
    final png = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0, 0, 0, 0,
    ]);
    final avatar = avatarFromBytes(png);

    expect(avatar, isNotNull);
    expect(avatar!.mime, 'image/png');
    expect(avatar.base64Data, isNotEmpty);
    expect(avatarFromBytes(Uint8List.fromList([0x47, 0x49, 0x46])), isNull);
    expect(avatarFromBytes(Uint8List(0)), isNull);
    expect(avatarFromBytes(Uint8List(512 * 1024 + 1)), isNull);
  });
}
