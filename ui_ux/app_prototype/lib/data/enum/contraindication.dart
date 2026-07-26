// Kopie aus Graphen (Injury Class/Individuals)
enum Contraindication {
  ankleIssue,
  backIssue,
  balanceIssue,
  coreWeakness,
  hamstringIssue,
  hipIssue,
  kneeIssue,
  lowerBackIssue,
  neckIssue,
  respiratoryIssue,
  shoulderIssue,
  spineIssue,
  upperBackIssue,
  wristIssue,
  none
}

extension ContraindicationExt on Contraindication {
  String get label {
    switch (this) {
      case Contraindication.ankleIssue:
        return "Sprunggelenkprobleme";
      case Contraindication.backIssue:
        return "Rückenprobleme";
      case Contraindication.balanceIssue:
        return "Gleichgewichtsprobleme";
      case Contraindication.coreWeakness:
        return "Rumpfmuskelschwäche";
      case Contraindication.hamstringIssue:
        return "Oberschenkelrückseiten-Beschwerden";
      case Contraindication.hipIssue:
        return "Hüftprobleme";
      case Contraindication.kneeIssue:
        return "Knieschmerzen";
      case Contraindication.lowerBackIssue:
        return "Probleme im unteren Rücken";
      case Contraindication.neckIssue:
        return "Nackenprobleme";
      case Contraindication.respiratoryIssue:
        return "Atemwegsproblem";
      case Contraindication.shoulderIssue:
        return "Schulterprobleme";
      case Contraindication.spineIssue:
        return "Wirbelsäulenprobleme";
      case Contraindication.upperBackIssue:
        return "Probleme im oberen Rücken";
      case Contraindication.wristIssue:
        return "Handgelenkprobleme";
      case Contraindication.none:
        return "Keine Einschränkungen";
    }
  }

  String get labelEN {
    switch (this) {
      case Contraindication.ankleIssue:
        return "AnkleIssue";
      case Contraindication.backIssue:
        return "BackIssue";
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
      case Contraindication.respiratoryIssue:
        return "RespiratoryIssue";
      case Contraindication.shoulderIssue:
        return "ShoulderIssue";
      case Contraindication.spineIssue:
        return "SpineIssue";
      case Contraindication.upperBackIssue:
        return "UpperBackIssue";
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
      case Contraindication.backIssue:
        return _backIssueDesc;
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
      case Contraindication.respiratoryIssue:
        return _respiratoryIssueDesc;
      case Contraindication.shoulderIssue:
        return _shoulderIssueDesc;
      case Contraindication.spineIssue:
        return _spineIssueDesc;
      case Contraindication.upperBackIssue:
        return _upperBackIssueDesc;
      case Contraindication.wristIssue:
        return _wristIssueDesc;
      case Contraindication.none:
        return "";
    }
  }

  String get shortLabel {
    switch (this) {
      case Contraindication.ankleIssue:
        return "Sprunggelenk";
      case Contraindication.backIssue:
        return "Rücken";
      case Contraindication.balanceIssue:
        return "Gleichgewicht";
      case Contraindication.coreWeakness:
        return "Rumpf";
      case Contraindication.hamstringIssue:
        return "Beinbeuger";
      case Contraindication.hipIssue:
        return "Hüfte";
      case Contraindication.kneeIssue:
        return "Knie";
      case Contraindication.lowerBackIssue:
        return "Unterer Rücken";
      case Contraindication.neckIssue:
        return "Nacken";
      case Contraindication.respiratoryIssue:
        return "Atemwege";
      case Contraindication.shoulderIssue:
        return "Schulter";
      case Contraindication.spineIssue:
        return "Wirbelsäule";
      case Contraindication.upperBackIssue:
        return "Oberer Rücken";
      case Contraindication.wristIssue:
        return "Handgelenk";
      case Contraindication.none:
        return "Keine";
    }
  }

  static Contraindication fromString(String value) {
    switch (value) {
      case "AnkleIssue":
        return Contraindication.ankleIssue;
      case "BackIssue":
        return Contraindication.backIssue;
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
      case "RespiratoryIssue":
        return Contraindication.respiratoryIssue;
      case "NeckIssue":
        return Contraindication.neckIssue;
      case "ShoulderIssue":
        return Contraindication.shoulderIssue;
      case "SpineIssue":
        return Contraindication.spineIssue;
      case "UpperBackIssue":
        return Contraindication.upperBackIssue;
      case "WristIssue":
        return Contraindication.wristIssue;
      default:
        return Contraindication.none;
    }
  }
}

// Texte aus Ontologie Stand 25.07 von EN zu DE übersetzt.
const String _ankleIssueDesc =
    "Instabilität, frühere Verletzung oder Schmerzen im Bereich der Sprunggelenke.";

const String _backIssueDesc =
    "Beschwerden oder Verletzungen im Rückenbereich, die Übungen einschränken können.";

const String _balanceIssueDesc =
    "Schwierigkeiten, das Gleichgewicht zu halten, etwa durch Schwindel oder Muskelschwäche.";

const String _coreWeaknessDesc =
    "Schwäche der Rumpfmuskulatur, die Haltung und Stabilität beeinträchtigt.";

const String _hamstringIssueDesc =
    "Verspannung oder Schmerz in der hinteren Oberschenkelmuskulatur.";

const String _hipIssueDesc =
    "Steifigkeit, Fehlstellung oder Schmerzen im Bereich der Hüfte.";

const String _kneeIssueDesc =
    "Verletzung, Instabilität oder Belastung im Bereich des Kniegelenks.";

const String _lowerBackIssueDesc =
    "Beschwerden oder Belastungsrisiko im Lendenwirbelbereich der Wirbelsäule.";

const String _neckIssueDesc =
    "Verspannung oder Schmerz im Bereich der Halswirbelsäule.";

const String _respiratoryIssueDesc =
    "Vorsicht bei fortgeschrittenen Atemwegserkrankungen wie COPD oder Asthma, da längere Atempausen oder forcierte Atemmuster die Symptome verschlechtern können. Rücksprache mit einem Arzt wird empfohlen.";

const String _shoulderIssueDesc =
    "Schmerzen, Verspannungen oder Bewegungseinschränkungen im Schulterbereich.";

const String _spineIssueDesc =
    "Allgemeine Empfindlichkeit oder Instabilität im Bereich der Wirbelsäule.";

const String _upperBackIssueDesc =
    "Beschwerden oder Schmerzen im Bereich der Brustwirbelsäule.";

const String _wristIssueDesc =
    "Schmerz, Schwäche oder Instabilität im Bereich des Handgelenks.";
