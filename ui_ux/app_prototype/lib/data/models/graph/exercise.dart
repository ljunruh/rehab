import 'package:isar/isar.dart';

part 'exercise.g.dart';

@Collection()
class Exercise {
  Id isarId = Isar.autoIncrement;
  final String id;
  final String label;
  final String difficulty;

  //TODO[API]: Hier String oder Enum nutzen?
  final List<String> trainingsEffects;
  final List<String> bodyParts;

  Exercise({
    required this.id,
    required this.label,
    required this.difficulty,
    required this.trainingsEffects,
    required this.bodyParts
  });

  factory Exercise.fromSparqlJson(Map<String, dynamic> json) {
    Exercise exercise = Exercise(
      id: json['exercise']['value'] ?? '',
      label: json['exerciseLabel']['value'] ?? '',
      difficulty: json['difficultyLabel']?['value'] ?? '',
      trainingsEffects: json['trainingsEffects']?['value'],
      bodyParts: _toStringList(json['bodyParts']?['value']),
    );
    return exercise;
  }

  //TODO[API] Muss in ein CoreModel oder ModelService ausgelagert werden
  static List<String> _toStringList(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
