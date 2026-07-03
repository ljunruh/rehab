/// Auswahl-Optionen für die Plan-Erstellung (Person 2).
///
/// Reine UI-Konstanten, übernommen aus dem JSX-Prototyp.
class PlanOptions {
  PlanOptions._();

  /// Körperregionen zur Auswahl.
  static const List<String> regions = [
    'Knie',
    'Schulter',
    'Rücken',
    'Hüfte',
    'Nacken',
    'Sprunggelenk',
  ];

  /// Trainingsziele (kurz, für Chips).
  static const List<String> goals = [
    'Mobilität',
    'Kraft',
    'Stabilität',
    'Entspannung',
  ];

  /// Schwierigkeitsgrade.
  static const List<String> difficulties = [
    'Leicht',
    'Mittel',
    'Anspruchsvoll',
  ];

  /// Filter-Optionen für die Übungsauswahl (Region-Filter inkl. "Alle").
  static const List<String> regionFilter = [
    'Alle',
    'Knie',
    'Schulter',
    'Rücken',
    'Hüfte',
    'Nacken',
  ];
}
