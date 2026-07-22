import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/models/api/plan_log_exercise.dart';
import 'package:app_prototype/data/repository/plan_log_exercise_repository.dart';
import 'package:flutter/material.dart';

class PlanLogExerciseProvider extends ChangeNotifier {
  final PlanLogExerciseRepository repo;

  PlanLogExerciseProvider(this.repo) {
    loadTodayLogs();
  }

  List<PlanLogExercise> _todayLogs = [];
  List<PlanLogExercise> get todayLogs => _todayLogs;

  Future<void> loadTodayLogs() async {
    _todayLogs = await repo.getLogsForDate(DateTime.now());
    notifyListeners();
  }

  /// Wird aufgerufen, wenn eine Übung im Trainings-Flow abgeschlossen wird
  Future<void> logExercise({required String planId, required String exerciseId}) async {
    await repo.saveLog(planId, exerciseId);
    await loadTodayLogs(); // UI aktualisieren
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
}