/// Modell einer Reha-Übung (reines UI-Modell).
///
/// Entspricht den Übungs-Objekten aus dem JSX-Prototyp. Enthält bewusst
/// KEINE JSON-Serialisierung — das Anbinden an eine API ist Aufgabe der
/// Backend-/API-Gruppe.
class Exercise {
  final String id;
  final String name;
  final String region;
  final String duration; // z.B. "4 Min"
  final String? durationSec; // z.B. "04:12"
  final String difficulty; // Leicht | Mittel | Anspruchsvoll
  final String description;
  final List<String> steps;
  final List<String> safety;
  final bool done;

  const Exercise({
    required this.id,
    required this.name,
    required this.region,
    required this.duration,
    this.durationSec,
    required this.difficulty,
    required this.description,
    this.steps = const [],
    this.safety = const [],
    this.done = false,
  });

  Exercise copyWith({
    String? name,
    String? region,
    String? duration,
    String? durationSec,
    String? difficulty,
    String? description,
    List<String>? steps,
    List<String>? safety,
    bool? done,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      region: region ?? this.region,
      duration: duration ?? this.duration,
      durationSec: durationSec ?? this.durationSec,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      safety: safety ?? this.safety,
      done: done ?? this.done,
    );
  }
}
