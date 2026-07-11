import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/graph/exercise.dart';
import 'package:isar/isar.dart';

class ExerciseService {
  /* TODO[API]: Hier wahrscheinlich kein Isar notwendig sondern nur Filter funktionen
  final Isar isar;

  ExerciseService(this.isar);

  Future<List<Exercise>> getAll() {
    return isar.exercises.where().findAll();
  }

  Future<void> saveAll(List<Exercise> list) async {
    await isar.writeTxn(() async {
      await isar.exercises.clear();
      await isar.exercises.putAll(list);
    });
  }
  */

  /// Filtert eine Liste von Übungen lokal nach Körperregion, Trainingsziel und Suchbegriff (Ra.T).
  List<Exercise> filterExercises(
    List<Exercise> all, {
    required BodyPart bodyPart,
    required Goal goal,
    String query = '',
  }) {
    return all.where((exercise) {
      // 1. Filter nach Körperregion (bodyPart)
      if (bodyPart != BodyPart.none) {
        final matchesBodyPart = exercise.bodyParts.any((bp) {
          final cleanBp = bp.trim().toLowerCase();
          return cleanBp == bodyPart.name.toLowerCase() ||
              cleanBp == bodyPart.label.toLowerCase() ||
              cleanBp == bodyPart.labelEN.toLowerCase();
        });
        if (!matchesBodyPart) return false;
      }

      // 2. Filter nach Trainingsziel (goal)
      if (goal != Goal.none) {
        final matchesGoal = exercise.trainingsEffects.any((te) {
          final cleanTe = te.trim().toLowerCase();
          return cleanTe == goal.name.toLowerCase() ||
              cleanTe == goal.label.toLowerCase() ||
              cleanTe == goal.labelEN.toLowerCase();
        });
        if (!matchesGoal) return false;
      }

      // 3. Filter nach Suchbegriff (query)
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesQuery =
            exercise.label.toLowerCase().contains(q) ||
            exercise.description.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      return true;
    }).toList();
  }
}
