import 'package:flutter_test/flutter_test.dart';

import 'package:digital_platform_for_telemedicine/services/public_facilities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the saved open data has clinic hours and hospitals', () async {
    final facilities = await PublicFacilities.load();
    final clinics = facilities.where((facility) => facility.kind == 'clinic');
    final hospitals = facilities.where((facility) => facility.isHospital);

    expect(clinics.length, 77);
    expect(hospitals.length, 44);
    expect(clinics.every((facility) => facility.hoursEn.trim().isNotEmpty), isTrue);
    expect(
      hospitals.every((facility) => facility.hoursEn.isEmpty),
      isTrue,
    );
    expect(
      clinics
          .firstWhere(
            (facility) =>
                facility.nameEn == 'Kwun Tong Family Medicine Integrated Centre',
          )
          .hoursTc,
      contains('星期一'),
    );
  });
}
