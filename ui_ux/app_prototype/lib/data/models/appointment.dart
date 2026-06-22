/// Modell eines Praxis-Termins (reines UI-Modell).
class Appointment {
  final String id;
  final String day; // "22"
  final String month; // "Mai"
  final String weekday; // "Donnerstag"
  final String time; // "14:30"
  final String practice;
  final String room;
  final String therapist;
  final String address;
  final String type; // Behandlungsart

  const Appointment({
    required this.id,
    required this.day,
    required this.month,
    required this.weekday,
    required this.time,
    required this.practice,
    required this.room,
    required this.therapist,
    required this.address,
    required this.type,
  });
}
