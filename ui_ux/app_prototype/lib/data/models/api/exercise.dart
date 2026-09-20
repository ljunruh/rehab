import 'package:isar/isar.dart';

part 'exercise.g.dart';

@Embedded()
class Exercise {
  // Onotlogie Object Properties
  late String id;
  late String label;
  late String difficulty;
  //TODO[API]: Hier String oder Enum nutzen?
  late List<String> trainingsEffects;
  late List<String> bodyParts;
  // Onotlogie Data Properties
  late String description;
  late int duration;
  late List<String> instructions;
  //TODO[API]: Hier String oder Enum nutzen?
  late List<String> corrections;
  late List<String> mistakes;
  late String video;

  List<String> get hints {
    return [...corrections, ...mistakes];
  }

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
    required this.instructions,
    required this.corrections,
    required this.mistakes,
    required this.video
  });

  Exercise copyWith({
    String? id,
    String? label,
    String? difficulty,
    List<String>? trainingsEffects,
    List<String>? bodyParts,
    String? description,
    int? duration,
    List<String>? instruction,
    List<String>? corrections,
    List<String>? mistakes,
    String? video
  }) {
    return Exercise.create(
      id: id ?? this.id,
      label: label ?? this.label,
      difficulty: difficulty ?? this.difficulty,
      trainingsEffects: trainingsEffects ?? this.trainingsEffects,
      bodyParts: bodyParts ?? this.bodyParts,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      instructions: instruction ?? this.instructions,
      corrections: corrections ?? this.corrections,
      mistakes: mistakes ?? this.mistakes,
      video: video ?? this.video,
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
      duration: _parseDuration(json['duration']?['value']),
      instructions: _splitTextByNumbers(json['instruction']?['value']),
      corrections: _toStringList(json['corrections']?['value']),
      mistakes: _toStringList(json['mistakes']?['value']),
      video: _firstNonEmpty([json['video']?['value'], json['pic']?['value']]) ??
          _buildVideoUrl(json['exercise']?['value'])
    );
    return exercise;
  }

  /// Für lokales Testen mit noch nicht hochgeladenen Videos, z.B.:
  /// flutter run --dart-define=LOCAL_VIDEO_DIR=/Users/name/Developer/rehab-local-videos
  /// Wenn gesetzt, werden Videos von dort geladen statt vom Video-Server.
  static const String _localVideoDir = String.fromEnvironment('LOCAL_VIDEO_DIR');

  /// Leitet aus dem lokalen Namen der Exercise-IRI (z.B. ".../PhysicalTherapy#Plank")
  /// die Video-URL für lokales Testen ab (Schema: lowercase-name + .mp4).
  /// Ohne LOCAL_VIDEO_DIR oder ohne hasVideoUrl vom Server gibt es kein Video,
  /// damit im Widget kein Fehler für Übungen ohne Video auftreten kann.
  static String _buildVideoUrl(String? exerciseIri) {
    if (_localVideoDir.isEmpty || exerciseIri == null || !exerciseIri.contains('#')) {
      return '';
    }
    final slug = exerciseIri.split('#').last.toLowerCase();
    return '$_localVideoDir/$slug.mp4';
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
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

  static int _parseDuration(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) {
        return int.parse(match.group(0)!);
      }
    }
    return 0;
  }

  static List<String> _splitTextByNumbers(String? value) {
    if (value == null) return [];
    final regex = RegExp(r'\d+\.\s');
    return value
        .split(regex)
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
  }
}
