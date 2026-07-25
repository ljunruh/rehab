import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/api_models.dart';
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

  //TODO[API]: Besprechen was die Bedingungen für eine Streak sind. Wann bricht sie ab wann wird gezählt?
  /// Prüft, ob in einer bestimmten Kalenderwoche mindestens ein Plan
  /// sein Wochenziel (sessionsPerWeek) erreicht hat.
  Future<int> getWeeklyStreak(List<Plan> activePlans) async {
    final allLogs = await isar.planLogExercises.where().findAll();
    if (allLogs.isEmpty || activePlans.isEmpty) return 1;

    // 1. Gruppiere Logs nach "Jahr-Woche" UND "PlanID"
    // Map-Struktur: {'2026-30': {'plan_1': 3, 'plan_2': 1}}
    final Map<String, Map<String, int>> weeklyPlanSessions = {};

    for (final log in allLogs) {
      final weekKey = '${log.timestamp.year}-${log.timestamp.weekNumber}';

      weeklyPlanSessions.putIfAbsent(weekKey, () => {});
      final planMap = weeklyPlanSessions[weekKey]!;

      // Zähle die Absolvierungen pro Plan in dieser Woche
      planMap[log.planId] = (planMap[log.planId] ?? 0) + 1;
    }

    // 2. Bestimme, welche Wochen als "erfolgreich/vollständig" gelten
    final completedWeeks = <String>{};

    weeklyPlanSessions.forEach((weekKey, planCounts) {
      bool weekSuccessful = false;

      for (final plan in activePlans) {
        final doneCount = planCounts[plan.id] ?? 0;

        // Eine Woche gilt als geschafft, wenn die absolvierten Einheiten
        // das Wochenziel des Plans erreichen oder übertreffen.
        if (plan.sessionsPerWeek > 0 && doneCount >= plan.sessionsPerWeek) {
          weekSuccessful = true;
          break; // Ein erfolgreicher Plan reicht für die Woche
        }
      }

      if (weekSuccessful) {
        completedWeeks.add(weekKey);
      }
    });

    // 3. Rückwärts-Prüfung ab HEUTE
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final key = '${checkDate.year}-${checkDate.weekNumber}';

      if (completedWeeks.contains(key)) {
        streak++;
        // Gehe 7 Tage zurück in die Vorwoche
        checkDate = checkDate.subtract(const Duration(days: 7));
      } else {
        // Sonderfall: Aktuelle Woche ist noch nicht geschafft, aber die Vorwoche war erfolgreich.
        // Streak soll nicht abreißen, während die aktuelle Woche noch läuft!
        if (streak == 0) {
          final lastWeek = checkDate.subtract(const Duration(days: 7));
          final lastWeekKey = '${lastWeek.year}-${lastWeek.weekNumber}';

          if (completedWeeks.contains(lastWeekKey)) {
            checkDate = lastWeek; // Springe zur Vorwoche und prüfe weiter
            continue;
          }
        }

        // 🔴 HIER REISST DIE STREAK AB:
        // Sobald eine vergangene Woche nicht in `completedWeeks` enthalten ist,
        // stoppt die Schleife und der bisherige Zählerstand steht fest.
        break;
      }
    }

    return streak > 0 ? streak : 1;
  }

  /// Ermittelt alle Pläne, die an einem bestimmten Tag vollständig absolviert wurden.
  /// Ein Plan gilt als abgeschlossen, wenn für alle seine Übungen mindestens ein Log an diesem Tag vorliegt.
  Future<List<Plan>> getCompletedPlansForDate({
    required DateTime date,
    required List<Plan> availablePlans,
  }) async {
    final logsOnDate = await getLogsForDate(date);
    if (logsOnDate.isEmpty) return [];

    final completedPlans = <Plan>[];

    for (final plan in availablePlans) {
      if (plan.exercises.isEmpty) continue;

      // Alle absolvierten Übung-IDs des Tages für diesen Plan filtern
      final loggedExerciseIds = logsOnDate
          .where((log) => log.planId == plan.id)
          .map((log) => log.exerciseId)
          .toSet();

      // Prüfen, ob jede Übung des Plans in den Logs vertreten ist
      final isCompleted = plan.exercises.every(
            (ex) => loggedExerciseIds.contains(ex.id),
      );

      if (isCompleted) {
        completedPlans.add(plan);
      }
    }

    return completedPlans;
  }

  //TODO[API]: Test um WeeklyStreak zu simulieren und Fake Daten dafür anzulegen
  /// Erstellt gefakte historische Logs für `weeksBack` Wochen in der Vergangenheit.
  /// Berücksichtigt die aktiven Pläne und deren Wochenziele (sessionsPerWeek).
  Future<void> insertFakeHistoricalLogs(int weeksBack, List<Plan> activePlans) async {
    final now = DateTime.now();

    await isar.writeTxn(() async {
      // Falls keine Pläne übergeben wurden, nutzen wir einen Fallback-Plan
      final targetPlans = activePlans.isNotEmpty
          ? activePlans
          : [Plan(id: 'test_plan', name: 'test_name', region: BodyPart.ankles, goal: Goal.balance, sessionsPerWeek: 1, exercises: [])];

      for (int weekIndex = 0; weekIndex < weeksBack; weekIndex++) {
        for (final plan in targetPlans) {
          final requiredSessions = plan.sessionsPerWeek > 0 ? plan.sessionsPerWeek : 1;

          // Er erstelle pro Woche so viele Logs, wie das Wochenziel verlangt (z.B. verteilt auf Mo, Mi, Fr)
          for (int sessionIndex = 0; sessionIndex < requiredSessions; sessionIndex++) {
            final fakeDate = now
                .subtract(Duration(days: weekIndex * 7))
                .subtract(Duration(days: sessionIndex * 2)); // Verteilt über die Woche

            final log = PlanLogExercise(
              planId: plan.id,
              exerciseId: plan.exercises.isNotEmpty
                  ? plan.exercises.first.id
                  : 'test_exercise',
              timestamp: fakeDate,
            );

            await isar.planLogExercises.put(log);
          }
        }
      }
    });
  }
}