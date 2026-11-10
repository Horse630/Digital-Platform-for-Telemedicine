import 'package:shared_preferences/shared_preferences.dart';

/// Short notes kept on this device after an action such as booking a visit.
class ActionNotices {
  static const storageKey = 'ui_notice_lines';

  static Future<void> add(String line) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lines = prefs.getStringList(storageKey) ?? <String>[];
      lines.insert(0, line);
      await prefs.setStringList(storageKey, lines.take(20).toList());
    } catch (_) {
      // The visit is already saved. The note is only a local reminder.
    }
  }

  static Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(storageKey) ?? const [];
    } catch (_) {
      return const [];
    }
  }
}
