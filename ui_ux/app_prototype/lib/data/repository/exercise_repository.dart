import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/models/graph/exercise.dart';
import 'package:app_prototype/data/service/exercise_service.dart';

class ExerciseRepository {
  final ExerciseService service;
  final ExerciseApi api;

  ExerciseRepository({required this.service, required this.api});

  Future<List<Exercise>?> getAll() => api.fetchExercises();

  Future<void> saveAll(List<Exercise> list) => service.saveAll(list);

}