// Kopie aus Graphen (Injury Class/Individuals)
enum Injury {
  ankleIssue,
  balanceIssue,
  coreWeakness,
  hamstringIssue,
  hipIssue,
  kneeIssue,
  lowerBackIssue,
  neckIssue,
  shoulderIssue,
  spineIssue,
  wristIssue,
  none
}

extension InjuryExt on Injury {
  String get label {
    switch (this) {
      case Injury.ankleIssue:
        return "Sprunggelenksbeschwerden";
      case Injury.balanceIssue:
        return "Gleichgewichtsprobleme";
      case Injury.coreWeakness:
        return "Rumpfschwäche";
      case Injury.hamstringIssue:
        return "Oberschenkelrückseite-Beschwerden (Hamstrings)";
      case Injury.hipIssue:
        return "Hüftbeschwerden";
      case Injury.kneeIssue:
        return "Kniebeschwerden";
      case Injury.lowerBackIssue:
        return "Schmerzen im unteren Rücken";
      case Injury.neckIssue:
        return "Nackenbeschwerden";
      case Injury.shoulderIssue:
        return "Schulterbeschwerden";
      case Injury.spineIssue:
        return "Wirbelsäulenprobleme";
      case Injury.wristIssue:
        return "Handgelenksbeschwerden";
      case Injury.none:
        return "Keine Einschränkungen";
    }
  }

  String get labelEN {
    switch (this) {
      case Injury.ankleIssue:
        return "AnkleIssue";
      case Injury.balanceIssue:
        return "BalanceIssue";
      case Injury.coreWeakness:
        return "CoreWeakness";
      case Injury.hamstringIssue:
        return "HamstringIssue";
      case Injury.hipIssue:
        return "HipIssue";
      case Injury.kneeIssue:
        return "KneeIssue";
      case Injury.lowerBackIssue:
        return "LowerBackIssue";
      case Injury.neckIssue:
        return "NeckIssue";
      case Injury.shoulderIssue:
        return "ShoulderIssue";
      case Injury.spineIssue:
        return "SpineIssue";
      case Injury.wristIssue:
        return "WristIssue";
      case Injury.none:
        return "None";
    }
  }

  String get description {
    switch (this) {
      case Injury.ankleIssue:
        return _ankleIssueDesc;
      case Injury.balanceIssue:
        return _balanceIssueDesc;
      case Injury.coreWeakness:
        return _coreWeaknessDesc;
      case Injury.hamstringIssue:
        return _hamstringIssueDesc;
      case Injury.hipIssue:
        return _hipIssueDesc;
      case Injury.kneeIssue:
        return _kneeIssueDesc;
      case Injury.lowerBackIssue:
        return _lowerBackIssueDesc;
      case Injury.neckIssue:
        return _neckIssueDesc;
      case Injury.shoulderIssue:
        return _shoulderIssueDesc;
      case Injury.spineIssue:
        return _spineIssueDesc;
      case Injury.wristIssue:
        return _wristIssueDesc;
      case Injury.none:
        return "";
    }
  }

  static Injury fromString(String value) {
    switch (value) {
      case "AnkleIssue":
        return Injury.ankleIssue;
      case "BalanceIssue":
        return Injury.balanceIssue;
      case "CoreWeakness":
        return Injury.coreWeakness;
      case "HamstringIssue":
        return Injury.hamstringIssue;
      case "HipIssue":
        return Injury.hipIssue;
      case "KneeIssue":
        return Injury.kneeIssue;
      case "LowerBackIssue":
        return Injury.lowerBackIssue;
      case "NeckIssue":
        return Injury.neckIssue;
      case "ShoulderIssue":
        return Injury.shoulderIssue;
      case "SpineIssue":
        return Injury.spineIssue;
      case "WristIssue":
        return Injury.wristIssue;
      default:
        return Injury.none;
    }
  }
}

// Texte aus Ontologie Stand 28.06 von EN zu DE übersetzt.
const String _ankleIssueDesc =
    "Instabilität, frühere Verletzung oder Schmerzen im Sprunggelenk.";

const String _balanceIssueDesc =
    "Schwierigkeiten, das Gleichgewicht zu halten aufgrund vestibulärer oder muskulärer Faktoren.";

const String _coreWeaknessDesc =
    "Schwäche der Bauch- und Rückenmuskulatur, die Balance oder Körperhaltung beeinträchtigt.";

const String _hamstringIssueDesc =
    "Verspannung oder Zerrung der hinteren Oberschenkelmuskulatur.";

const String _hipIssueDesc =
    "Gelenksteifigkeit, Fehlstellung oder Beschwerden im Hüftbereich.";

const String _kneeIssueDesc =
    "Verletzungen, Instabilität oder Belastungsprobleme im Kniegelenk.";

const String _lowerBackIssueDesc =
    "Beschwerden oder Belastungsrisiko im Lendenwirbelbereich der Wirbelsäule.";

const String _neckIssueDesc =
    "Verspannungen, Instabilität oder Verletzungen im Hals- bzw. Nackenbereich.";

const String _shoulderIssueDesc =
    "Schmerzen, Verspannungen oder Bewegungseinschränkungen im Schulterbereich.";

const String _spineIssueDesc =
    "Allgemeine Empfindlichkeit oder Instabilität der Wirbelsäule, z. B. Skoliose.";

const String _wristIssueDesc =
    "Schmerzen, Schwäche oder Instabilität im Handgelenk.";
