// Kopie aus Graphen (Injury Class/Individuals)
enum Contraindication {
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

extension InjuryExt on Contraindication {
  String get label {
    switch (this) {
      case Contraindication.ankleIssue:
        return "Sprunggelenksbeschwerden";
      case Contraindication.balanceIssue:
        return "Gleichgewichtsprobleme";
      case Contraindication.coreWeakness:
        return "Rumpfschwäche";
      case Contraindication.hamstringIssue:
        return "Oberschenkelrückseite-Beschwerden (Hamstrings)";
      case Contraindication.hipIssue:
        return "Hüftbeschwerden";
      case Contraindication.kneeIssue:
        return "Kniebeschwerden";
      case Contraindication.lowerBackIssue:
        return "Schmerzen im unteren Rücken";
      case Contraindication.neckIssue:
        return "Nackenbeschwerden";
      case Contraindication.shoulderIssue:
        return "Schulterbeschwerden";
      case Contraindication.spineIssue:
        return "Wirbelsäulenprobleme";
      case Contraindication.wristIssue:
        return "Handgelenksbeschwerden";
      case Contraindication.none:
        return "Keine Einschränkungen";
    }
  }

  String get labelEN {
    switch (this) {
      case Contraindication.ankleIssue:
        return "AnkleIssue";
      case Contraindication.balanceIssue:
        return "BalanceIssue";
      case Contraindication.coreWeakness:
        return "CoreWeakness";
      case Contraindication.hamstringIssue:
        return "HamstringIssue";
      case Contraindication.hipIssue:
        return "HipIssue";
      case Contraindication.kneeIssue:
        return "KneeIssue";
      case Contraindication.lowerBackIssue:
        return "LowerBackIssue";
      case Contraindication.neckIssue:
        return "NeckIssue";
      case Contraindication.shoulderIssue:
        return "ShoulderIssue";
      case Contraindication.spineIssue:
        return "SpineIssue";
      case Contraindication.wristIssue:
        return "WristIssue";
      case Contraindication.none:
        return "None";
    }
  }

  String get description {
    switch (this) {
      case Contraindication.ankleIssue:
        return _ankleIssueDesc;
      case Contraindication.balanceIssue:
        return _balanceIssueDesc;
      case Contraindication.coreWeakness:
        return _coreWeaknessDesc;
      case Contraindication.hamstringIssue:
        return _hamstringIssueDesc;
      case Contraindication.hipIssue:
        return _hipIssueDesc;
      case Contraindication.kneeIssue:
        return _kneeIssueDesc;
      case Contraindication.lowerBackIssue:
        return _lowerBackIssueDesc;
      case Contraindication.neckIssue:
        return _neckIssueDesc;
      case Contraindication.shoulderIssue:
        return _shoulderIssueDesc;
      case Contraindication.spineIssue:
        return _spineIssueDesc;
      case Contraindication.wristIssue:
        return _wristIssueDesc;
      case Contraindication.none:
        return "";
    }
  }

  static Contraindication fromString(String value) {
    switch (value) {
      case "AnkleIssue":
        return Contraindication.ankleIssue;
      case "BalanceIssue":
        return Contraindication.balanceIssue;
      case "CoreWeakness":
        return Contraindication.coreWeakness;
      case "HamstringIssue":
        return Contraindication.hamstringIssue;
      case "HipIssue":
        return Contraindication.hipIssue;
      case "KneeIssue":
        return Contraindication.kneeIssue;
      case "LowerBackIssue":
        return Contraindication.lowerBackIssue;
      case "NeckIssue":
        return Contraindication.neckIssue;
      case "ShoulderIssue":
        return Contraindication.shoulderIssue;
      case "SpineIssue":
        return Contraindication.spineIssue;
      case "WristIssue":
        return Contraindication.wristIssue;
      default:
        return Contraindication.none;
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
