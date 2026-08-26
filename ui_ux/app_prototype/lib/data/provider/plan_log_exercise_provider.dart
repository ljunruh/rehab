import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/models/api/plan_log_exercise.dart';
import 'package:app_prototype/data/repository/plan_log_exercise_repository.dart';
import 'package:flutter/material.dart';

class PlanLogExerciseProvider extends ChangeNotifier {
  final PlanLogExerciseRepository repo;

  PlanLogExerciseProvider(this.repo) {
    loadTodayLogs();
  }

  List<PlanLogExercise> _allLogs = [];
  List<PlanLogExercise> get allLogs => _allLogs;
  List<PlanLogExercise> _todayLogs = [];
  List<PlanLogExercise> get todayLogs => _todayLogs;
  int _weeklyStreak = 0;
  int get weeklyStreak => _weeklyStreak;

  /// Lädt die heutigen Logs und berechnet den Streak basierend auf den aktiven Plänen neu
  Future<void> loadTodayLogs({List<Plan> activePlans = const []}) async {
    _allLogs = await repo.getAllLogs();
    _todayLogs = await repo.getLogsForDate(DateTime.now());
    _weeklyStreak = await repo.getWeeklyStreak(activePlans); //  Hier übergeben
    // TEMP: Test-Override, damit Recipe-Unlock in der App direkt pruefbar ist. _weeklyStreak dafür erhöhen
    //_weeklyStreak = 1;
    notifyListeners();
  }

  /// Wird aufgerufen, wenn eine Übung im Trainings-Flow abgeschlossen wird
  Future<void> logExercise({
    required String planId,
    required String exerciseId,
    List<Plan> activePlans = const [],
  }) async {
    await repo.saveLog(planId, exerciseId);
    await loadTodayLogs(activePlans: activePlans);
  }

  /// Berechnet den Fortschritt eines Plans für HEUTE
  ({int done, int total}) getTodayProgress(Plan plan) {
    final total = plan.exercises.length;
    if (total == 0) return (done: 0, total: 0);

    // Filtert alle heutigen Logs, die zu diesem Plan gehören
    final completedExerciseIds = _todayLogs
        .where((log) => log.planId == plan.id)
        .map((log) => log.exerciseId)
        .toSet();

    final done = plan.exercises.where((ex) => completedExerciseIds.contains(ex.id)).length;

    return (done: done, total: total);
  }

  /// Prüft, ob eine bestimmte Übung eines Plans heute bereits absolviert wurde
  bool isExerciseCompletedToday(String planId, String exerciseId) {
    return _todayLogs.any((log) => log.planId == planId && log.exerciseId == exerciseId);
  }

  /// Prüft, ob alle Übungen eines Plans heute bereits absolviert wurden
  bool areAllExercisesCompletedToday(Plan plan) {
    if (plan.exercises.isEmpty) return false;
    return plan.exercises.every((ex) => isExerciseCompletedToday(plan.id, ex.id));
  }

  /// Prüft, ob der nächste Klick auf eine Übung den Plan vollständig abschließt
  bool willCompleteAllWithThisClick(Plan plan, String currentExerciseId) {
    if (areAllExercisesCompletedToday(plan)) return true;

    final isCurrentDone = isExerciseCompletedToday(plan.id, currentExerciseId);
    if (isCurrentDone) return false;

    final completedCount = plan.exercises
        .where((ex) => isExerciseCompletedToday(plan.id, ex.id))
        .length;

    // Wenn aktuell genau (Anzahl - 1) Übungen fertig sind, schließt dieser Klick alles ab
    return completedCount + 1 == plan.exercises.length;
  }

  /// Liefert den Index der ersten Übung, die heute noch nicht erledigt wurde (-1 wenn alle fertig sind)
  int getNextOpenExerciseIndex(Plan plan) {
    return plan.exercises.indexWhere((ex) => !isExerciseCompletedToday(plan.id, ex.id));
  }

  /// Berechnet abgeschlossene Pläne für ein bestimmtes Kalender-Datum
  Future<List<Plan>> getCompletedPlansForDate(DateTime date, List<Plan> allPlans) async {
    return await repo.getCompletedPlansForDate(
      date: date,
      availablePlans: allPlans,
    );
  }

  /// Prüft für das Kalender-Dotting, ob an einem bestimmten Tag mindestens 1 Plan abgeschlossen wurde
  Future<bool> hasCompletedPlanOnDate(DateTime date, List<Plan> allPlans) async {
    final completed = await getCompletedPlansForDate(date, allPlans);
    return completed.isNotEmpty;
  }

  /// Neu: Holt den Fortschritt aller gestarteten Pläne für ein bestimmtes Kalender-Datum
  Future<List<PlanDayProgress>> getPlanProgressForDate(DateTime date, List<Plan> allPlans) async {
    return await repo.getPlanProgressForDate(
      date: date,
      availablePlans: allPlans,
    );
  }

  /// Berechnet die Anzahl der in der AKTUELLEN Woche vollständig absolvierten
  /// Sessions für einen Plan (1 Session = alle Übungen des Plans an einem Tag gemacht).
  int calculateWeeklyCompletedSessionsForPlan(Plan plan) {
    if (plan.exercises.isEmpty) return 0;

    final now = DateTime.now();
    // Montag der aktuellen Woche (00:00:00 Uhr)
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    int completedCount = 0;

    // Gehe alle Tage der aktuellen Woche von Montag bis heute durch
    for (int i = 0; i < 7; i++) {
      final currentDay = monday.add(Duration(days: i));

      // Tage in der Zukunft müssen nicht geprüft werden
      if (currentDay.isAfter(now)) break;

      // Alle absolvierten Übungs-IDs für diesen Tag und diesen Plan sammeln
      final completedExerciseIdsOnDay = _allLogs
          .where((log) =>
      log.planId == plan.id &&
          log.timestamp.year == currentDay.year &&
          log.timestamp.month == currentDay.month &&
          log.timestamp.day == currentDay.day)
          .map((log) => log.exerciseId)
          .toSet();

      // Prüfen, ob JEDE Übung des Plans an diesem Tag geloggt wurde
      final allDoneOnDay = plan.exercises.every(
            (ex) => completedExerciseIdsOnDay.contains(ex.id),
      );

      if (allDoneOnDay) {
        completedCount++;
      }
    }

    return completedCount;
  }

  /// Berechnet die `completedSessions` für alle übergebenen Pläne neu
  Map<String, int> recalculateCompletedSessionsForAllPlans(List<Plan> plans) {
    final Map<String, int> resultMap = {};
    for (final plan in plans) {
      resultMap[plan.id] = calculateWeeklyCompletedSessionsForPlan(plan);
    }
    return resultMap;
  }

  /// Löscht Log-Einträge im gewählten Zeitraum, lädt die Daten neu
  /// und gibt die neu berechneten `completedSessions` pro Plan-ID zurück.
  Future<Map<String, int>> deleteLogsBetween(
      DateTime fromDate,
      DateTime toDate, {
        List<Plan> activePlans = const [],
      }) async {
    // 1. Einträge aus Isar löschen
    await repo.deletePlanLogExercisesBetween(fromDate, toDate);

    // 2. Lokale Logs neu aus der Datenbank laden
    await loadTodayLogs(activePlans: activePlans);

    // 3. Neu berechnete completedSessions für alle aktiven Pläne ermitteln und zurückgeben
    return recalculateCompletedSessionsForAllPlans(activePlans);
  }

  //TODO[API]: Test um WeeklyStreak zu simulieren und Fake Daten dafür anzulegen
  Future<void> seedTestData(int weeks, {List<Plan> activePlans = const []}) async {
    await repo.insertFakeHistoricalLogs(weeks, activePlans);
    await loadTodayLogs(activePlans: activePlans); // Berechnet den Streak neu
  }
}