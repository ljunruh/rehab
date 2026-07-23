import 'package:app_prototype/data/models/api/pain_log_exercise.dart';
import 'package:app_prototype/data/models/api/plan_log_exercise.dart';
import 'package:isar/isar.dart';

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
}