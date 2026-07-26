// Kopie aus Graphen (TrainingsEffect Class/Individuals)
import 'package:flutter/material.dart';

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

  //Wird für Mapping von Knowledge Graph Label Annotation genutzt
  String get labelEN {
    switch (this) {
      case Goal.balance:
        return "Balance";
      case Goal.coordination:
        return "Coordination";
      case Goal.flexibility:
        return "Flexibility";
      case Goal.focus:
        return "Focus";
      case Goal.mobility:
        return "Mobility";
      case Goal.posture:
        return "Posture";
      case Goal.relaxation:
        return "Relaxation";
      case Goal.stability:
        return "Stability";
      case Goal.strength:
        return "Strength";
      case Goal.none:
        return "None";
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

  ({String label, IconData icon}) get rubrik {
    switch (this) {
      case Goal.strength:
        return (label: 'KRAFT', icon: Icons.bolt);
      case Goal.coordination:
      case Goal.balance:
      case Goal.stability:
      case Goal.posture:
        return (label: 'KOORDINATION', icon: Icons.gps_fixed);
      case Goal.relaxation:
        return (label: 'ENTSPANNUNG', icon: Icons.spa);
      case Goal.flexibility:
      case Goal.focus:
      case Goal.mobility:
      case Goal.none:
        return (label: 'MOBILISATION', icon: Icons.waves);
    }
  }
}