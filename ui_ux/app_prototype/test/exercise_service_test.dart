import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExerciseApi extends Fake implements ExerciseApi {}
class FakeUserRepository extends Fake implements UserRepository {}

void main() {
  group('ExerciseRepository Filter Tests', () {
    final repository = ExerciseRepository(
      api: FakeExerciseApi(),
      userRepository: FakeUserRepository(),
    );

    final List<Exercise> testExercises = [
      Exercise.create(
        id: '1',
        label: 'Kniebeuge',
        difficulty: 'Mittel',
        trainingsEffects: const ['strength', 'stability'],
        bodyParts: const ['knees', 'legs'],
        description: 'Eine Kniebeuge',
        duration: 5,
        instructions: const ['In die Hocke gehen'],
        corrections: const [],
        mistakes: const [],
        video: '',
      ),
      Exercise.create(
        id: '2',
        label: 'Schulterdrehen',
        difficulty: 'Leicht',
        trainingsEffects: const ['mobility'],
        bodyParts: const ['shoulders'],
        description: 'Arme kreisen',
        duration: 3,
        instructions: const ['Schultern bewegen'],
        corrections: const [],
        mistakes: const [],
        video: '',
      ),
      Exercise.create(
        id: '3',
        label: 'Rumpfbeuge',
        difficulty: 'Mittel',
        trainingsEffects: const ['flexibility', 'stability'],
        bodyParts: const ['back', 'core'],
        description: 'Rumpf dehnen',
        duration: 4,
        instructions: const ['Nach vorne beugen'],
        corrections: const [],
        mistakes: const [],
        video: '',
      ),
    ];

    test('should filter by body part', () {
      final results = repository.filterExercises(
        testExercises,
        bodyPart: BodyPart.knees,
        goal: Goal.none,
      );

      expect(results.length, 1);
      expect(results.first.label, 'Kniebeuge');
    });

    test('should filter by goal', () {
      final results = repository.filterExercises(
        testExercises,
        bodyPart: BodyPart.none,
        goal: Goal.mobility,
      );

      expect(results.length, 1);
      expect(results.first.label, 'Schulterdrehen');
    });

    test('should filter by both body part and goal', () {
      final results = repository.filterExercises(
        testExercises,
        bodyPart: BodyPart.back,
        goal: Goal.stability,
      );

      expect(results.length, 1);
      expect(results.first.label, 'Rumpfbeuge');
    });

    test('should filter by search query', () {
      final results = repository.filterExercises(
        testExercises,
        bodyPart: BodyPart.none,
        goal: Goal.none,
        query: 'Knie',
      );

      expect(results.length, 1);
      expect(results.first.label, 'Kniebeuge');
    });

    test('should return empty list if no matches', () {
      final results = repository.filterExercises(
        testExercises,
        bodyPart: BodyPart.elbows,
        goal: Goal.relaxation,
      );

      expect(results.isEmpty, true);
    });
  });
}
