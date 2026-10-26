import 'package:digital_platform_for_telemedicine/services/appointment_api.dart';
import 'package:digital_platform_for_telemedicine/services/appointment_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final slots = [
    _slot(
      id: 'late-chan',
      name: 'Chan',
      types: const ['Dermatology'],
      at: DateTime.utc(2026, 11, 10, 2),
    ),
    _slot(
      id: 'early-lee',
      name: 'Lee',
      types: const ['General Practice', 'Cardiology'],
      at: DateTime.utc(2026, 11, 5, 2),
    ),
    _slot(
      id: 'mid-lee',
      name: 'Lee',
      types: const ['Cardiology'],
      at: DateTime.utc(2026, 11, 7, 2),
    ),
  ];

  test('a name search keeps matching doctors and sorts by time', () {
    final result = filterAppointments(
      slots,
      const AppointmentQuery(doctorName: 'lee'),
    );

    expect(result.map((item) => item.id), ['early-lee', 'mid-lee']);
  });

  test('a doctor type keeps slots that include that type', () {
    final result = filterAppointments(
      slots,
      const AppointmentQuery(doctorType: 'Cardiology'),
    );

    expect(result.map((item) => item.id), ['early-lee', 'mid-lee']);
  });

  test('name sort uses the doctor name, then the time', () {
    final result = filterAppointments(
      slots,
      const AppointmentQuery(sort: AppointmentSort.nameAscending),
    );

    expect(result.map((item) => item.id), ['late-chan', 'early-lee', 'mid-lee']);
  });
}

AppointmentRecord _slot({
  required String id,
  required String name,
  required List<String> types,
  required DateTime at,
}) {
  return AppointmentRecord(
    id: id,
    scheduledAt: at,
    status: 'available',
    reason: '',
    doctorName: name,
    doctorSpecialty: types.join(', '),
    doctorTypes: types,
    patientName: null,
  );
}
