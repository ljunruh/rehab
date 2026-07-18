import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
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

  Future<List<Exercise>?> getFilterdExcercises(BodyPart bodyPart, Goal goal) async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchExercisesByParamsExcludeContraindications(bodyPart, goal, [], SkillLevel.intermediate);
    }

    final result = api.fetchExercisesByParamsExcludeContraindications(
      bodyPart,
      goal,
      user.contraindication,
      user.skillLevel,
    );
    return result;
  }

}