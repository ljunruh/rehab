// Kopie aus Graphen (TrainingsLevel Class/Individuals)
enum SkillLevel {
  beginner,
  intermediate,
  advanced
}

extension SkillLevelExt on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.beginner:
        return "Anfänger";
      case SkillLevel.intermediate:
        return "Fortgeschrittener";
      case SkillLevel.advanced:
        return "Profi";
    }
  }

  String get description {
    switch (this) {
      case SkillLevel.beginner:
        return _beginnerDescription;
      case SkillLevel.intermediate:
        return _intermediateDescription;
      case SkillLevel.advanced:
        return _advancedDescription;
    }
  }

  static SkillLevel fromString(String value) {
    switch (value) {
      case "beginner":
        return SkillLevel.beginner;
      case "intermediate":
        return SkillLevel.intermediate;
      case "advanced":
        return SkillLevel.advanced;
      default:
        return SkillLevel.beginner;
    }
  }
}

// Texte aus Discord Chat
const String _beginnerDescription = '''
1. Bürojob, leichte Hausarbeit, ab und zu Sport

2. Mache öfter Sport, bin evtl. im Haushalt ziemlich aktiv oder auf der Arbeit,
   aber habe auch oft Schmerzen
''';

const String _intermediateDescription = '''
1. Regelmäßiger Sport, aber moderat, ein kleiner Sprint ist locker drin

2. Sportlich, eine 6 km Wanderung oder 30 Minuten Fahrrad fahren sind kein
   Problem, trotz leichter Schmerzen durch eine Verletzung
''';

const String _advancedDescription = '''
1. Sportlich und keine Schmerzen

2. Regelmäßiges Training mehrmals pro Woche, intensive Belastungen,
   längere Ausdaueraktivitäten oder Krafttraining können ohne
   Einschränkungen durchgeführt werden.
''';