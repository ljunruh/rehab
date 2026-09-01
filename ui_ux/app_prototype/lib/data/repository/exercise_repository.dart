import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/contraindication.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:app_prototype/data/repository/user_repository.dart';

class ExerciseRepository {
  final ExerciseApi api;
  final UserRepository userRepository;

  ExerciseRepository({required this.api, required this.userRepository});

  Future<List<Exercise>?> getAll() async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchAllExercisesExcludeContraindications([], []);
    }

    return api.fetchAllExercisesExcludeContraindications(user.contraindications, user.joints);
  }

  Future<List<Exercise>?> getFilterdExcercises(BodyPart bodyPart, Goal goal) async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchExercisesByParamsExcludeContraindications(bodyPart, goal, SkillLevel.intermediate, [], []);
    }

    final result = api.fetchExercisesByParamsExcludeContraindications(
      bodyPart,
      goal,
      user.skillLevel,
      user.contraindications,
      user.joints
    );
    return result;
  }

  /// Filtert eine Liste von Übungen lokal nach Körperregion, Trainingsziel und Suchbegriff .
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