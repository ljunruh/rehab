import 'package:isar/isar.dart';

part 'exercise.g.dart';

@Collection()
class Exercise {
  Id isarId = Isar.autoIncrement;
  final String id;
  final String label;
  final String comment;

  Exercise({
    required this.id,
    required this.label,
    required this.comment,
  });

  factory Exercise.fromSparqlJson(Map<String, dynamic> json) {
    Exercise exercise = Exercise(
      id: json['exercise']['value'] ?? '',
      label: json['label']['value'] ?? '',
      comment: json['comment']?['value'] ?? '',
    );
    return exercise;
  }
}
