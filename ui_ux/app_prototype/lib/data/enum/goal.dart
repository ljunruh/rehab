// Kopie aus Graphen (TrainingsEffect Class/Individuals)
enum Goal {
  balance,
  coordination,
  flexibility,
  focus,
  mobility,
  posture,
  relaxation,
  stability,
  strength,
  none,
}

extension GoalExt on Goal {
  String get label {
    switch (this) {
      case Goal.balance:
        return "Balance";
      case Goal.coordination:
        return "Koordination";
      case Goal.flexibility:
        return "Flexibilität";
      case Goal.focus:
        return "Konzentration";
      case Goal.mobility:
        return "Beweglichkeit";
      case Goal.posture:
        return "Körperhaltung";
      case Goal.relaxation:
        return "Entspannung";
      case Goal.stability:
        return "Stabilität";
      case Goal.strength:
        return "Kraft";
      case Goal.none:
        return "Keines";
    }
  }

  static Goal fromString(String value) {
    switch (value) {
      case "balance":
        return Goal.balance;
      case "coordination":
        return Goal.coordination;
      case "flexibility":
        return Goal.flexibility;
      case "focus":
        return Goal.focus;
      case "mobility":
        return Goal.mobility;
      case "posture":
        return Goal.posture;
      case "relaxation":
        return Goal.relaxation;
      case "stability":
        return Goal.stability;
      case "strength":
        return Goal.strength;
      default:
        return Goal.none;
    }
  }
}