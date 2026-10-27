import 'appointment_api.dart';

/// How a patient orders the appointment list.
enum AppointmentSort { soonest, latest, nameAscending, nameDescending }

/// Name text, one doctor type, and a sort. Empty name and a null type keep every row.
class AppointmentQuery {
  const AppointmentQuery({
    this.doctorName = '',
    this.doctorType,
    this.sort = AppointmentSort.soonest,
  });

  final String doctorName;
  final String? doctorType;
  final AppointmentSort sort;

  bool get isFiltering =>
      doctorName.trim().isNotEmpty ||
      (doctorType != null && doctorType!.isNotEmpty);
}

/// Keeps rows whose doctor name contains [AppointmentQuery.doctorName]
/// and whose types include [AppointmentQuery.doctorType], then sorts them.
List<AppointmentRecord> filterAppointments(
  List<AppointmentRecord> appointments,
  AppointmentQuery query,
) {
  final name = query.doctorName.trim().toLowerCase();
  final type = query.doctorType;
  final matched = [
    for (final item in appointments)
      if (_matches(item, name, type)) item,
  ];
  matched.sort((a, b) => _compare(a, b, query.sort));
  return matched;
}

bool _matches(AppointmentRecord item, String name, String? type) {
  if (name.isNotEmpty && !item.doctorName.toLowerCase().contains(name)) {
    return false;
  }
  if (type != null && !item.doctorTypes.contains(type)) {
    return false;
  }
  return true;
}

/// The soonest future row with status `scheduled`. Open slots are not a booking.
AppointmentRecord? nextScheduledAppointment(
  List<AppointmentRecord> appointments, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final upcoming = [
    for (final item in appointments)
      if (item.status == 'scheduled' && item.scheduledAt.isAfter(clock)) item,
  ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  if (upcoming.isEmpty) {
    return null;
  }
  return upcoming.first;
}

int _compare(AppointmentRecord a, AppointmentRecord b, AppointmentSort sort) {
  switch (sort) {
    case AppointmentSort.soonest:
      return a.scheduledAt.compareTo(b.scheduledAt);
    case AppointmentSort.latest:
      return b.scheduledAt.compareTo(a.scheduledAt);
    case AppointmentSort.nameAscending:
      final byName = a.doctorName.toLowerCase().compareTo(
        b.doctorName.toLowerCase(),
      );
      return byName != 0 ? byName : a.scheduledAt.compareTo(b.scheduledAt);
    case AppointmentSort.nameDescending:
      final byName = b.doctorName.toLowerCase().compareTo(
        a.doctorName.toLowerCase(),
      );
      return byName != 0 ? byName : a.scheduledAt.compareTo(b.scheduledAt);
  }
}
