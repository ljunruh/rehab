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

  Future<List<Exercise>?> getFilterdExcercises() async {
    final user = await userRepository.getUser();
    if (user == null) {
      return api.fetchFilteredExercises(BodyPart.none, Goal.none, 1, [], SkillLevel.intermediate);
    }

    final bodyPart = _parseBodyPart(user.region);
    final goal = _parseGoal(user.goal);
    final injuries = user.injuries.map((i) => InjuryExt.fromString(i)).toList();

    final result = api.fetchFilteredExercises(
      bodyPart,
      goal,
      1, // painLevel standardmäßig 1
      injuries,
      user.skillLevel,
    );
    return result;
  }

  BodyPart _parseBodyPart(String? r) {
    if (r == null) return BodyPart.none;
    switch (r.toLowerCase()) {
      case 'knie':
        return BodyPart.knees;
      case 'schulter':
      case 'schultern':
        return BodyPart.shoulders;
      case 'rücken':
        return BodyPart.back;
      case 'hüfte':
        return BodyPart.hip;
      case 'nacken':
        return BodyPart.neck;
      case 'sprunggelenk':
      case 'sprunggelenke':
        return BodyPart.ankles;
      case 'handgelenk':
      case 'handgelenke':
        return BodyPart.wrists;
      case 'ellbogen':
        return BodyPart.elbows;
      case 'beine':
        return BodyPart.legs;
      case 'arme':
        return BodyPart.arms;
      default:
        return BodyPart.none;
    }
  }

  Goal _parseGoal(String? g) {
    if (g == null) return Goal.none;
    switch (g.toLowerCase()) {
      case 'mobilität':
      case 'beweglichkeit':
        return Goal.mobility;
      case 'kraft':
        return Goal.strength;
      case 'stabilität':
        return Goal.stability;
      case 'entspannung':
        return Goal.relaxation;
      case 'balance':
        return Goal.balance;
      case 'koordination':
        return Goal.coordination;
      case 'flexibilität':
        return Goal.flexibility;
      case 'konzentration':
      case 'focus':
        return Goal.focus;
      default:
        return Goal.none;
    }
  }

  Future<void> saveAll(List<Exercise> list) => service.saveAll(list);

}