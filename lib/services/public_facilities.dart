import 'dart:convert';

import 'package:flutter/services.dart';

/// A public clinic or hospital saved from the Hospital Authority open data.
///
/// The file is a snapshot. The map does not call the source URLs.
class PublicFacility {
  const PublicFacility({
    required this.kind,
    required this.nameEn,
    required this.nameTc,
    required this.nameSc,
    required this.hoursEn,
    required this.hoursTc,
    required this.accidentEmergency,
    required this.latitude,
    required this.longitude,
  });

  final String kind;
  final String nameEn;
  final String nameTc;
  final String nameSc;
  final String hoursEn;
  final String hoursTc;
  final bool accidentEmergency;
  final double latitude;
  final double longitude;

  bool get isHospital => kind == 'hospital';

  String nameFor(String languageCode) {
    if (languageCode == 'zh_Hans') {
      return nameSc.isEmpty ? nameTc : nameSc;
    }
    if (languageCode == 'zh_Hant') {
      return nameTc.isEmpty ? nameEn : nameTc;
    }
    return nameEn;
  }

  /// Clinic hours exist in English and Traditional Chinese.
  /// The source has no simplified-Chinese hours, so simplified uses Traditional.
  String hoursFor(String languageCode) {
    final raw = languageCode == 'en' ? hoursEn : hoursTc;
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  factory PublicFacility.fromJson(Map<String, dynamic> json) {
    return PublicFacility(
      kind: json['kind'] is String ? json['kind'] as String : '',
      nameEn: json['nameEn'] is String ? json['nameEn'] as String : '',
      nameTc: json['nameTc'] is String ? json['nameTc'] as String : '',
      nameSc: json['nameSc'] is String ? json['nameSc'] as String : '',
      hoursEn: json['hoursEn'] is String ? json['hoursEn'] as String : '',
      hoursTc: json['hoursTc'] is String ? json['hoursTc'] as String : '',
      accidentEmergency: json['accidentEmergency'] == true,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class PublicFacilities {
  const PublicFacilities._();

  static const assetPath = 'assets/public_facilities.json';

  static Future<List<PublicFacility>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final rows = decoded['facilities'];
    if (rows is! List) {
      return const [];
    }
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) PublicFacility.fromJson(row),
    ];
  }
}
