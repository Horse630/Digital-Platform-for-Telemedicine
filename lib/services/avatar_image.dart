import 'dart:convert';
import 'dart:typed_data';

/// A profile photo the settings page can store in MongoDB.
class AvatarPayload {
  const AvatarPayload({required this.base64Data, required this.mime});

  final String base64Data;
  final String mime;
}

/// Accepts a JPEG, PNG, or WebP file up to 512 KB.
AvatarPayload? avatarFromBytes(Uint8List bytes) {
  const maxBytes = 512 * 1024;
  if (bytes.isEmpty || bytes.length > maxBytes) {
    return null;
  }
  final mime = _mime(bytes);
  if (mime == null) {
    return null;
  }
  return AvatarPayload(base64Data: base64Encode(bytes), mime: mime);
}

String? _mime(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'image/webp';
  }
  return null;
}
