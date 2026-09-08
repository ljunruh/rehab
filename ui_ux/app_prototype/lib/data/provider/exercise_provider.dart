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

  /// Lädt Übungen für eine Körperregion (inkl. Unterregionen) und optional
  /// mehrere Trainingsziele. [goals] leer bzw. nicht gesetzt = alle Ziele.
  Future<void> loadAll({
    BodyPart bodyPart = BodyPart.none,
    List<Goal> goals = const [],
  }) async {
    _exercises = await repo.getFilterdExcercises(bodyPart, goals) ?? [];
    notifyListeners();
  }
}
