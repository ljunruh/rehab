import 'package:isar/isar.dart';

part 'condition.g.dart';

@Collection()
class Condition {
  Id isarId = Isar.autoIncrement;
  final String id;
  final String label;
  final String comment;

  Condition({
    required this.id,
    required this.label,
    required this.comment,
  });

  factory Condition.fromSparqlJson(Map<String, dynamic> json) {
    return Condition(
      id: json['condition']['value'] ?? '',
      label: json['label']['value'] ?? '',
      comment: json['comment']?['value'] ?? '',
    );
  }
}
