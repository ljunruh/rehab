import 'package:isar/isar.dart';

part 'plan_log_exercise.g.dart';

@Collection()
class PlanLogExercise {
  Id isarId = Isar.autoIncrement;

  @Index()
  final String planId;

  final String exerciseId;

  @Index()
  final DateTime timestamp;

  PlanLogExercise({
    required this.planId,
    required this.exerciseId,
    required this.timestamp,
  });
}