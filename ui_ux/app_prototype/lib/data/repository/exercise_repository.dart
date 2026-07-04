import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/injury.dart';
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

  Future<List<Exercise>?> getFilterdExcercises(BodyPart bodyPart, Goal goal) async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchFilteredExercises(bodyPart, goal, [], SkillLevel.intermediate);
    }

    final result = api.fetchFilteredExercises(
      bodyPart,
      goal,
      user.injuries,
      user.skillLevel,
    );
    return result;
  }

  Future<void> saveAll(List<Exercise> list) => service.saveAll(list);

}