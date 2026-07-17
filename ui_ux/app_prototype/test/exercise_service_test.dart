import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:app_prototype/data/service/exercise_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseService Tests', () {
    final service = ExerciseService();

    final List<Exercise> testExercises = [
      Exercise.create(
        id: '1',
        label: 'Kniebeuge',
        difficulty: 'Mittel',
        trainingsEffects: const ['strength', 'stability'],
        bodyParts: const ['knees', 'legs'],
        description: 'Eine Kniebeuge',
        duration: 5,
        instruction: 'In die Hocke gehen',
        corrections: const [],
        mistakes: const [],
      ),
      Exercise.create(
        id: '2',
        label: 'Schulterdrehen',
        difficulty: 'Leicht',
        trainingsEffects: const ['mobility'],
        bodyParts: const ['shoulders'],
        description: 'Arme kreisen',
        duration: 3,
        instruction: 'Schultern bewegen',
        corrections: const [],
        mistakes: const [],
      ),
      Exercise.create(
        id: '3',
        label: 'Rumpfbeuge',
        difficulty: 'Mittel',
        trainingsEffects: const ['flexibility', 'stability'],
        bodyParts: const ['back', 'core'],
        description: 'Rumpf dehnen',
        duration: 4,
        instruction: 'Nach vorne beugen',
        corrections: const [],
        mistakes: const [],
      ),
    ];

    test('should filter by body part', () {
      final results = service.filterExercises(
        testExercises,
        bodyPart: BodyPart.knees,
        goal: Goal.none,
      );

      expect(results.length, 1);
      expect(results.first.label, 'Kniebeuge');
    });

    test('should filter by goal', () {
      final results = service.filterExercises(
        testExercises,
        bodyPart: BodyPart.none,
        goal: Goal.mobility,
      );

      expect(results.length, 1);
      expect(results.first.label, 'Schulterdrehen');
    });

    test('should filter by both body part and goal', () {
      final results = service.filterExercises(
        testExercises,
        bodyPart: BodyPart.back,
        goal: Goal.stability,
      );

      expect(results.length, 1);
      expect(results.first.label, 'Rumpfbeuge');
    });

    test('should filter by search query', () {
      final results = service.filterExercises(
        testExercises,
        bodyPart: BodyPart.none,
        goal: Goal.none,
        query: 'Knie',
      );

      expect(results.length, 1);
      expect(results.first.label, 'Kniebeuge');
    });

    test('should return empty list if no matches', () {
      final results = service.filterExercises(
        testExercises,
        bodyPart: BodyPart.elbows,
        goal: Goal.relaxation,
      );

      expect(results.isEmpty, true);
    });
  });
}
