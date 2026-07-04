import 'package:isar/isar.dart';

part 'exercise.g.dart';

@Collection()
class Exercise {
  Id isarId = Isar.autoIncrement;
  //Object Properties
  final String id;
  final String label;
  final String difficulty;
  //TODO[API]: Hier String oder Enum nutzen?
  final List<String> trainingsEffects;
  final List<String> bodyParts;
  //Data Properties
  final String description;
  final int duration;
  final String instruction;
  //TODO[API]: Hier String oder Enum nutzen?
  final List<String> corrections;
  final List<String> mistakes;


  Exercise({
    required this.id,
    required this.label,
    required this.difficulty,
    required this.trainingsEffects,
    required this.bodyParts,
    required this.description,
    required this.duration,
    required this.instruction,
    required this.corrections,
    required this.mistakes
  });

  factory Exercise.fromSparqlJson(Map<String, dynamic> json) {
    Exercise exercise = Exercise(
      id: json['exercise']?['value'] ?? '',
      label: json['exerciseLabel']?['value'] ?? '',
      difficulty: json['difficultyLabel']?['value'] ?? '',
      trainingsEffects: _toStringList(json['trainingsEffects']?['value']),
      bodyParts: _toStringList(json['bodyParts']?['value']),
      description: json['description']?['value'] ?? '',
      duration: json['duration']?['value'] is int
          ? json['duration']['value'] as int
          : int.tryParse(json['duration']?['value']?.toString() ?? '') ?? 0,
      instruction: json['instruction']?['value'] ?? '',
      corrections: _toStringList(json['corrections']?['value']),
      mistakes: _toStringList(json['mistakes']?['value']),
    );
    return exercise;
  }

  //TODO[API] Muss in ein CoreModel oder ModelService ausgelagert werden
  static List<String> _toStringList(String? value) {
    if (value == null) return [];
    return value
        .split(' | ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
