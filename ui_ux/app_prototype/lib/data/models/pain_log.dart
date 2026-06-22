/// Schmerz-Eintrag (Tagebuch) — reines UI-Modell.
class PainLog {
  final int level; // 0–10
  final String region;
  final String note;
  final DateTime date;
  final String dateKey; // "2026-06-10"

  const PainLog({
    required this.level,
    required this.region,
    this.note = '',
    required this.date,
    required this.dateKey,
  });

  /// Hilfsfunktion: erzeugt den Datums-Schlüssel "YYYY-MM-DD".
  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Kalender-Ereignis (Übung oder Termin) — reines UI-Modell.
class CalendarEvent {
  final String id;
  final String title;
  final String region;
  final String dateKey;
  final String time;
  final String type; // "exercise" | "appointment"
  final bool done;
  final String? note;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.region,
    required this.dateKey,
    this.time = '08:00',
    this.type = 'exercise',
    this.done = false,
    this.note,
  });
}
