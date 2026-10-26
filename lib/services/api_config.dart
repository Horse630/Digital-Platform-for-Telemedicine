import 'package:flutter/foundation.dart';

/// Base URL of the Node API.
///
/// An Android emulator reaches this computer through 10.0.2.2.
/// Web, desktop, and the iOS simulator use localhost.
/// A physical phone needs this computer's LAN address instead.
String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}
