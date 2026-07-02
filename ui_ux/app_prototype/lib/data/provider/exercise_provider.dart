import 'package:app_prototype/data/models/graph/exercise.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:flutter/material.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository repo;

  ExerciseProvider(this.repo);

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  Future<void> loadAll() async {
    _exercises = await repo.getFilterdExcercises() ?? [];
    notifyListeners();
  }
}