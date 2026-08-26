import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:flutter/material.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository repo;

  ExerciseProvider(this.repo);

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  Future<void> loadAll({BodyPart bodyPart = BodyPart.none, Goal goal = Goal.none}) async {
    _exercises = await repo.getFilterdExcercises(bodyPart, goal) ?? [];
    notifyListeners();
  }

  /// wir können da auch  cache und unser filter logik anwenden aber ich bin mir nicht sicher ob das gut ist ich lass das erst so wie es ist.
  /// Lädt alle Übungen für eine ausgewählte Körperregion zur Planerstellung über das SPARQL-Query (ohne Difficulty-Filter).
  Future<void> loadForPlanCreation(BodyPart bodyPart) async {
    _exercises = await repo.getExercisesForPlanCreation(bodyPart) ?? [];
    notifyListeners();
  }

  /// Lädt empfohlene Übungen für eine Körperregion und mehrere gewählte Trainingseffekte über das SPARQL-Query.
  Future<void> loadForRecommendation(
    BodyPart bodyPart,
    List<Goal> goals,
  ) async {
    _exercises =
        await repo.getExercisesForRecommendation(bodyPart, goals) ?? [];
    notifyListeners();
  }
}
