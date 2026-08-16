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
    _weeklyStreak = await repo.getWeeklyStreak(activePlans); // 👈 Hier übergeben
    // TEMP: Test-Override, damit Recipe-Unlock in der App direkt pruefbar ist. _weeklyStreak dafür erhöhen
    _weeklyStreak = 0;
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

  //TODO[API]: Test um WeeklyStreak zu simulieren und Fake Daten dafür anzulegen
  Future<void> seedTestData(int weeks, {List<Plan> activePlans = const []}) async {
    await repo.insertFakeHistoricalLogs(weeks, activePlans);
    await loadTodayLogs(activePlans: activePlans); // Berechnet den Streak neu
  }
}