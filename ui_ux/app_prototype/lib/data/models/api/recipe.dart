import 'package:isar/isar.dart';

part 'recipe.g.dart';

@Collection()
class Recipe {
  Id isarId;

  @Index(unique: true)
  final String id;

  /// Entspricht Ontology DataProperty `hasDescription`.
  final String hasDescription;

  /// Entspricht Ontology DataProperty `hasHealthBenefit`.
  final String hasHealthBenefit;

  /// Entspricht Ontology DataProperty `hasPreparationTime` (in Minuten).
  final int hasPreparationTime;

  /// Zeitpunkt, zu dem das Rezept freigeschaltet wurde.
  final DateTime unlockedAt;

  Recipe({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.hasDescription,
    required this.hasHealthBenefit,
    required this.hasPreparationTime,
    required this.unlockedAt,
  });

  @ignore
  String get displayTitle {
    final withoutPrefix = id.startsWith('Rezept_') ? id.substring(7) : id;
    return withoutPrefix.replaceAll('_', ' ');
  }

  String get displayDuration => '$hasPreparationTime min';
}

class RecipeCandidate {
  final String id;
  final String hasDescription;
  final String hasHealthBenefit;
  final int hasPreparationTime;

  const RecipeCandidate({
    required this.id,
    required this.hasDescription,
    required this.hasHealthBenefit,
    required this.hasPreparationTime,
  });

  factory RecipeCandidate.fromSparqlJson(Map<String, dynamic> json) {
    final prepRaw = json['hasPreparationTime']?['value']?.toString() ?? '0';
    final prep = double.tryParse(prepRaw)?.round() ?? 0;

    return RecipeCandidate(
      id: json['recipeId']?['value']?.toString() ?? '',
      hasDescription: json['hasDescription']?['value']?.toString() ?? '',
      hasHealthBenefit: json['hasHealthBenefit']?['value']?.toString() ?? '',
      hasPreparationTime: prep,
    );
  }
}
