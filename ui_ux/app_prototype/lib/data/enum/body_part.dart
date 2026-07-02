// Kopie aus Graphen (BodyPart Class/Individuals)
enum BodyPart {
  ankles,
  arms,
  back,
  biceps,
  calves,
  chest,
  core,
  elbows,
  glutes,
  hamstrings,
  hip,
  knees,
  legs,
  lowerBack,
  neck,
  obliques,
  pelvic,
  psoas,
  quadriceps,
  shoulders,
  spine,
  thighs,
  triceps,
  upperBack,
  wrists,
  none,
}

extension BodyPartExt on BodyPart {
  String get label {
    switch (this) {
      case BodyPart.ankles:
        return "Sprunggelenke";
      case BodyPart.arms:
        return "Arme";
      case BodyPart.back:
        return "Rücken";
      case BodyPart.biceps:
        return "Bizeps";
      case BodyPart.calves:
        return "Waden";
      case BodyPart.chest:
        return "Brust";
      case BodyPart.core:
        return "Rumpf";
      case BodyPart.elbows:
        return "Ellbogen";
      case BodyPart.glutes:
        return "Gesäß";
      case BodyPart.hamstrings:
        return "Hamstrings";
      case BodyPart.hip:
        return "Hüfte";
      case BodyPart.knees:
        return "Knie";
      case BodyPart.legs:
        return "Beine";
      case BodyPart.lowerBack:
        return "Unterer Rücken";
      case BodyPart.neck:
        return "Nacken";
      case BodyPart.obliques:
        return "Seitliche Bauchmuskulatur";
      case BodyPart.pelvic:
        return "Becken";
      case BodyPart.psoas:
        return "Psoas";
      case BodyPart.quadriceps:
        return "Quadrizeps";
      case BodyPart.shoulders:
        return "Schultern";
      case BodyPart.spine:
        return "Wirbelsäule";
      case BodyPart.thighs:
        return "Oberschenkel";
      case BodyPart.triceps:
        return "Trizeps";
      case BodyPart.upperBack:
        return "Oberer Rücken";
      case BodyPart.wrists:
        return "Handgelenke";
      case BodyPart.none:
        return "Keine";
    }
  }

  static BodyPart fromString(String value) {
    switch (value) {
      case "ankles":
        return BodyPart.ankles;
      case "arms":
        return BodyPart.arms;
      case "back":
        return BodyPart.back;
      case "biceps":
        return BodyPart.biceps;
      case "calves":
        return BodyPart.calves;
      case "chest":
        return BodyPart.chest;
      case "core":
        return BodyPart.core;
      case "elbows":
        return BodyPart.elbows;
      case "glutes":
        return BodyPart.glutes;
      case "hamstrings":
        return BodyPart.hamstrings;
      case "hip":
        return BodyPart.hip;
      case "knees":
        return BodyPart.knees;
      case "legs":
        return BodyPart.legs;
      case "lowerBack":
        return BodyPart.lowerBack;
      case "neck":
        return BodyPart.neck;
      case "obliques":
        return BodyPart.obliques;
      case "pelvic":
        return BodyPart.pelvic;
      case "psoas":
        return BodyPart.psoas;
      case "quadriceps":
        return BodyPart.quadriceps;
      case "shoulders":
        return BodyPart.shoulders;
      case "spine":
        return BodyPart.spine;
      case "thighs":
        return BodyPart.thighs;
      case "triceps":
        return BodyPart.triceps;
      case "upperBack":
        return BodyPart.upperBack;
      case "wrists":
        return BodyPart.wrists;
      default:
        return BodyPart.none;
    }
  }
}