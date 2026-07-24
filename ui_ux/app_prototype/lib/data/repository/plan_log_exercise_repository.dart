import 'package:app_prototype/data/models/api/pain_log_exercise.dart';
import 'package:app_prototype/data/models/api/plan_log_exercise.dart';
import 'package:isar/isar.dart';

extension DateTimeWeekExtension on DateTime {
  /// Berechnet die ISO-Kalenderwoche (1–53)
  int get weekNumber {
    final dayOfYear = int.parse(
      RegExp(r'\d+').firstMatch(
        DateTime(year, month, day).difference(DateTime(year, 1, 1)).toString(),
      )![0]!,
    );
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}

class PlanLogExerciseRepository {
  final Isar isar;

  PlanLogExerciseRepository(this.isar);

  /// Speichert ein einzelnes Übungs-Log
  Future<void> saveLog(String planId, String exerciseId) async {
    final log = PlanLogExercise(
      planId: planId,
      exerciseId: exerciseId,
      timestamp: DateTime.now(),
    );
    await isar.writeTxn(() async {
      await isar.planLogExercises.put(log);
    });
  }

  /// Holt alle Logs für einen bestimmten Tag (z. B. heute)
  Future<List<PlanLogExercise>> getLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return isar.planLogExercises
        .filter()
        .timestampBetween(startOfDay, endOfDay)
        .findAll();
  }

  /// Berechnet die Anzahl aufeinanderfolgender Kalenderwochen mit mindestens einem Training
  Future<int> getWeeklyStreak() async {
    final allLogs = await isar.planLogExercises.where().findAll();
    if (allLogs.isEmpty) return 1;

    final now = DateTime.now();

    // Wir gruppieren alle Logs nach "Jahr-Woche" (z.B. "2026-30")
    final trainedWeeks = <String>{};
    for (final log in allLogs) {
      final key = '${log.timestamp.year}-${log.timestamp.weekNumber}';
      trainedWeeks.add(key);
    }

    int streak = 0;
    DateTime checkDate = now;

    // Wir prüfen rückwärts Woche für Woche ab HEUTE
    while (true) {
      final key = '${checkDate.year}-${checkDate.weekNumber}';
      if (trainedWeeks.contains(key)) {
        streak++;
        // Gehe 7 Tage zurück in die Vorwoche
        checkDate = checkDate.subtract(const Duration(days: 7));
      } else {
        // Falls in der aktuellen Woche noch gar nichts trainiert wurde,
        // geben wir der vorherigen Woche noch eine Chance (Streak soll nicht sofort abreißem)
        if (streak == 0) {
          final lastWeek = checkDate.subtract(const Duration(days: 7));
          final lastWeekKey = '${lastWeek.year}-${lastWeek.weekNumber}';
          if (trainedWeeks.contains(lastWeekKey)) {
            checkDate = lastWeek;
            continue;
          }
        }
        break;
      }
    }

    return streak > 0 ? streak : 1;
  }
}