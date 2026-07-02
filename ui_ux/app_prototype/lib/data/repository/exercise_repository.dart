import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:app_prototype/data/models/graph/exercise.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:app_prototype/data/service/exercise_service.dart';

class ExerciseRepository {
  final ExerciseService service;
  final ExerciseApi api;
  final UserRepository userRepository;

  ExerciseRepository({required this.service, required this.api, required this.userRepository});

  Future<List<Exercise>?> getAll() => api.fetchAllExercises();

  Future<List<Exercise>?> getFilterdExcercises() async {
    final user = await userRepository.getUser();
    final result = api.fetchFilteredExercises(BodyPart.none, Goal.none, 1, [], SkillLevel.intermediate);
    return result;
  }

  Future<void> saveAll(List<Exercise> list) => service.saveAll(list);

}