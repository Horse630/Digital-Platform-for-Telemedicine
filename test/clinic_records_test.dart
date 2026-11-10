import 'package:digital_platform_for_telemedicine/services/appointment_api.dart';
import 'package:digital_platform_for_telemedicine/services/meeting_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a hosted meeting stays on the list before the patient can enter', () {
    final meeting = MeetingRecord.fromJson({
      'appointmentId': 'demo-appointment',
      'scheduledAt': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      'patientName': 'Patient',
      'doctorName': 'Doctor',
      'roomCode': '482910',
      'status': 'live',
      'waiting': false,
      'admitted': false,
      'canEnter': false,
    });

    expect(meeting.isOpen, isTrue);
    expect(meeting.canEnter, isFalse);
  });

  test('a visit note can carry a stomach-medicine warning', () {
    final visit = AppointmentRecord.fromJson({
      'id': 'visit-1',
      'scheduledAt': '2026-11-03T02:00:00.000Z',
      'status': 'completed',
      'reason': 'Sore throat',
      'visitNote': 'ibuprofen',
      'medicineWarning': true,
      'patientRating': null,
      'doctor': {
        'fullName': 'Doctor',
        'ratingAverage': 4.5,
      },
      'patient': {'fullName': 'Patient'},
    });

    expect(visit.status, 'completed');
    expect(visit.medicineWarning, isTrue);
    expect(visit.doctorRatingAverage, 4.5);
  });
}
