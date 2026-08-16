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
      return api.fetchAllExercisesExcludeContraindications([]);
    }

    return api.fetchAllExercisesExcludeContraindications(user.contraindication);
  }

  /**
   * Planerstellung: Lädt alle Übungen für eine bestimmte Körperregion (ohne Filterung nach Schwierigkeitsgrad).
   */
  Future<List<Exercise>?> getExercisesForPlanCreation(BodyPart bodyPart) async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchExercisesForPlanCreation(bodyPart, []);
    }
    return api.fetchExercisesForPlanCreation(bodyPart, user.contraindication);
  }

  /**
   * Planempfehlung: Lädt Übungen für eine Körperregion und mehrere gewählte Trainingseffekte (List<Goal>).
   */
  Future<List<Exercise>?> getExercisesForRecommendation(
    BodyPart bodyPart,
    List<Goal> goals,
  ) async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchExercisesForRecommendation(
        bodyPart,
        goals,
        [],
        SkillLevel.intermediate,
      );
    }
    return api.fetchExercisesForRecommendation(
      bodyPart,
      goals,
      user.contraindication,
      user.skillLevel,
    );
  }

  /// Veraltete Methode (wird durch getExercisesForRecommendation ersetzt).
  /// für sicherheit falls es noch was von alten methoden aufgerufen wird .
  Future<List<Exercise>?> getFilterdExcercises(
    BodyPart bodyPart,
    Goal goal,
  ) async {
    return getExercisesForRecommendation(bodyPart, [goal]);
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
