// Kopie aus Graphen (Joint)
enum Joint {
  ankleJoint,
  elbow,
  hipJoint,
  kneeJoint,
  neckJoint,
  upperBackJoint,
  shoulderJoint,
  spineJoint,
  lowerBackJoint,
  wristJoint,
  none,
}

extension JointExt on Joint {
  String get labelDE {
    switch (this) {
      case Joint.ankleJoint:
        return "Sprunggelenk";
      case Joint.elbow:
        return "Ellbogengelenk";
      case Joint.hipJoint:
        return "Hüftgelenk";
      case Joint.kneeJoint:
        return "Kniegelenk";
      case Joint.neckJoint:
        return "Halswirbelsäule";
      case Joint.upperBackJoint:
        return "Obere rückengelenke";
      case Joint.shoulderJoint:
        return "Schultergelenk";
      case Joint.spineJoint:
        return "Wirbelsäulengelenke";
      case Joint.lowerBackJoint:
        return "Untere Rückengelenke";
      case Joint.wristJoint:
        return "Handgelenk";
      case Joint.none:
        return "Kein";
    }
  }

  String get labelEN {
    switch (this) {
      case Joint.ankleJoint:
        return "Ankle joint";
      case Joint.elbow:
        return "Elbow joint";
      case Joint.hipJoint:
        return "Hip joint";
      case Joint.kneeJoint:
        return "Knee joint";
      case Joint.neckJoint:
        return "Neck joint";
      case Joint.upperBackJoint:
        return "Upper back joints";
      case Joint.shoulderJoint:
        return "Shoulder joint";
      case Joint.spineJoint:
        return "Spine joint";
      case Joint.lowerBackJoint:
        return "Lower back joints";
      case Joint.wristJoint:
        return "Wrist joint";
      case Joint.none:
        return "None";
    }
  }


  static Joint fromString(String value) {
    switch (value) {
      case "AnkleJoint":
        return Joint.ankleJoint;
      case "Elbow Joint":
        return Joint.elbow;
      case "HipJoint":
        return Joint.hipJoint;
      case "KneeJoint":
        return Joint.kneeJoint;
      case "NeckJoint":
        return Joint.neckJoint;
      case "Upper back joints":
        return Joint.upperBackJoint;
      case "ShoulderJoint":
        return Joint.shoulderJoint;
      case "SpineJoint":
        return Joint.spineJoint;
      case "Lower back joints":
        return Joint.lowerBackJoint;
      case "WristJoint":
        return Joint.wristJoint;
      default:
        return Joint.none;
    }
  }
}