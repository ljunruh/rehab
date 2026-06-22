import 'package:flutter/material.dart';

/// Datensatz für einen einzelnen Wochen-Fortschrittsring (Home-Screen).
///
/// Reines UI-Modell. Pro aktivem Plan ein Ring: zeigt erledigte Einheiten
/// im Verhältnis zum Wochenziel, in der Plan-Farbe.
class WeeklyRing {
  final String label;
  final Color color;
  final int done;
  final int goal;

  const WeeklyRing({
    required this.label,
    required this.color,
    required this.done,
    required this.goal,
  });

  /// Fortschritt 0.0–1.0.
  double get progress => goal <= 0 ? 0 : (done / goal).clamp(0.0, 1.0);
}
