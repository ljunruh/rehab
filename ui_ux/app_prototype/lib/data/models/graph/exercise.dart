import 'package:isar/isar.dart';

part 'exercise.g.dart';

@Embedded()
class Exercise {
  //Object Properties
  late String id;
  late String label;
  late String difficulty;
  //TODO[API]: Hier String oder Enum nutzen?
  late List<String> trainingsEffects;
  late List<String> bodyParts;
  //Data Properties
  late String description;
  late int duration;
  late String instruction;
  //TODO[API]: Hier String oder Enum nutzen?
  late List<String> corrections;
  late List<String> mistakes;

  //@Embedded() braucht leeren Konstruktor
  Exercise();

  Exercise.create({
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

  Exercise copyWith({
    String? id,
    String? label,
    String? difficulty,
    List<String>? trainingsEffects,
    List<String>? bodyParts,
    String? description,
    int? duration,
    String? instruction,
    List<String>? corrections,
    List<String>? mistakes,
  }) {
    return Exercise.create(
      id: id ?? this.id,
      label: label ?? this.label,
      difficulty: difficulty ?? this.difficulty,
      trainingsEffects: trainingsEffects ?? this.trainingsEffects,
      bodyParts: bodyParts ?? this.bodyParts,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      instruction: instruction ?? this.instruction,
      corrections: corrections ?? this.corrections,
      mistakes: mistakes ?? this.mistakes,
    );
  }

  factory Exercise.fromSparqlJson(Map<String, dynamic> json) {
    Exercise exercise = Exercise.create(
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
