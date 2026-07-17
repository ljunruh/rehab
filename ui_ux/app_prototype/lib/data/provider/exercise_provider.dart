import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:app_prototype/data/service/exercise_service.dart';
import 'package:flutter/material.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository repo;

  /// Instanz des ExerciseServices zur Durchführung der lokalen Filter-Logik
  final ExerciseService _service = ExerciseService();

  ExerciseProvider(this.repo);

  /// Lokaler In-Memory-Cache für alle geladenen Übungen, um doppelte API-Abfragen zu verhindern
  List<Exercise> _allExercises = [];

  /// Liste der aktuell gefilterten Übungen, die im UI angezeigt werden.
  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  /// Lädt alle Übungen (einmalig in den Cache) und filtert sie lokal über den ExerciseService.
  /// Verhindert wiederholte SPARQL-Netzwerkanfragen bei Filteränderungen im UI .
  Future<void> loadAll({
    BodyPart bodyPart = BodyPart.none,
    Goal goal = Goal.none,
    String query = '',
  }) async {
    // 1. Daten nur laden, wenn der Cache noch leer ist
    if (_allExercises.isEmpty) {
      _allExercises = await repo.getAll() ?? [];
    }

    // 2. Filterung lokal im Arbeitsspeicher über den Service ausführen
    _exercises = _service.filterExercises(
      _allExercises,
      bodyPart: bodyPart,
      goal: goal,
      query: query,
    );

    // 3. UI benachrichtigen, dass sich die Daten geändert haben
    notifyListeners();
  }
}
