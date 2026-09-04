import 'package:isar/isar.dart';

part 'daily_life_advice.g.dart';

@Collection()
class DailyLifeAdvice {
  Id isarId;

  @Index(unique: true)
  final String id;

  /// Körperregion (z.B. "Shoulder", "Knee", "Back", "Neck", "Hip")
  final String bodyPart;

  /// Kategorie/Kontext (z.B. "Sitzen", "Tragen", "Laufen")
  final String? category;

  /// Der Ratschlag selbst
  final String advice;

  /// Zeitpunkt, zu dem der Rat abgerufen wurde
  final DateTime fetchedAt;

  DailyLifeAdvice({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.bodyPart,
    this.category,
    required this.advice,
    required this.fetchedAt,
  });
}

/// Leichtgewichtiges DTO für API-Responses
class DailyLifeAdviceCandidate {
  final String id;
  final String bodyPart;
  final String? category;
  final String advice;

  const DailyLifeAdviceCandidate({
    required this.id,
    required this.bodyPart,
    this.category,
    required this.advice,
  });

  factory DailyLifeAdviceCandidate.fromSparqlJson(Map<String, dynamic> json) {
    return DailyLifeAdviceCandidate(
      id: (json['adviceId']?['value'] as String? ?? '').replaceAll(RegExp(r'^.*[#/]'), ''),
      bodyPart: (json['bodyPartLabel']?['value'] as String? ?? ''),
      category: json['category']?['value'] as String?,
      advice: (json['advice']?['value'] as String? ?? ''),
    );
  }

  DailyLifeAdvice toDailyLifeAdvice() {
    return DailyLifeAdvice(
      id: id,
      bodyPart: bodyPart,
      category: category,
      advice: advice,
      fetchedAt: DateTime.now(),
    );
  }
}
