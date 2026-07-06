import 'package:app_prototype/data/enum/gender.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  @enumerated
  late Gender gender;
  late int age;
  late int weight;
  late int height;

  /// Isar-safe: Enum als String speichern, da List Enums zu komplex.
  late List<String> contraindication;

  @enumerated
  late SkillLevel skillLevel;

  // optional UI-only / non-persisted fields
  @ignore
  String email = '';

  @ignore
  String goal = '';

  @ignore
  String region = '';

  @ignore
  List<String> regions = [];

  @ignore
  String mobility = '';

  @ignore
  String reminder = '';

  /// Initialen für Avatar
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  User({
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.contraindication,
    required this.skillLevel,

    // ✅ optional UI fields mit Defaults
    this.email = '',
    this.goal = '',
    this.region = '',
    this.regions = const [],
    this.mobility = '',
    this.reminder = '',
  });

  User copyWith({
    String? name,
    Gender? gender,
    int? age,
    int? weight,
    int? height,
    List<String>? injury,
    SkillLevel? skillLevel,

    String? email,
    String? goal,
    String? region,
    List<String>? regions,
    String? mobility,
    String? reminder,
  }) {
    return User(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      contraindication: injury ?? this.contraindication,
      skillLevel: skillLevel ?? this.skillLevel,

      email: email ?? this.email,
      goal: goal ?? this.goal,
      region: region ?? this.region,
      regions: regions ?? this.regions,
      mobility: mobility ?? this.mobility,
      reminder: reminder ?? this.reminder,
    );
  }
}