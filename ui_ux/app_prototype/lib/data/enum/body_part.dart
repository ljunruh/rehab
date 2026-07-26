// Kopie aus Graphen (BodyPart Class/Individuals)
import 'dart:ui';

import 'package:app_prototype/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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

  String get labelEN {
    switch (this) {
      case BodyPart.ankles:
        return "Ankles";
      case BodyPart.arms:
        return "Arms";
      case BodyPart.back:
        return "Back";
      case BodyPart.biceps:
        return "Biceps";
      case BodyPart.calves:
        return "Calves";
      case BodyPart.chest:
        return "Chest";
      case BodyPart.core:
        return "Core";
      case BodyPart.elbows:
        return "Elbows";
      case BodyPart.glutes:
        return "Glutes";
      case BodyPart.hamstrings:
        return "Hamstrings";
      case BodyPart.hip:
        return "Hip";
      case BodyPart.knees:
        return "Knees";
      case BodyPart.legs:
        return "Legs";
      case BodyPart.lowerBack:
        return "LowerBack";
      case BodyPart.neck:
        return "Neck";
      case BodyPart.obliques:
        return "Obliques";
      case BodyPart.pelvic:
        return "Pelvic";
      case BodyPart.psoas:
        return "Psoas";
      case BodyPart.quadriceps:
        return "Quadriceps";
      case BodyPart.shoulders:
        return "Shoulders";
      case BodyPart.spine:
        return "Spine";
      case BodyPart.thighs:
        return "Thighs";
      case BodyPart.triceps:
        return "Triceps";
      case BodyPart.upperBack:
        return "UpperBack";
      case BodyPart.wrists:
        return "Wrists";
      case BodyPart.none:
        return "None";
    }
  }

  static BodyPart fromString(String value) {
    switch (value) {
      case "Ankles":
        return BodyPart.ankles;
      case "Arms":
        return BodyPart.arms;
      case "Back":
        return BodyPart.back;
      case "Biceps":
        return BodyPart.biceps;
      case "Calves":
        return BodyPart.calves;
      case "Chest":
        return BodyPart.chest;
      case "Core":
        return BodyPart.core;
      case "Elbows":
        return BodyPart.elbows;
      case "Glutes":
        return BodyPart.glutes;
      case "Hamstrings":
        return BodyPart.hamstrings;
      case "Hip":
        return BodyPart.hip;
      case "Knees":
        return BodyPart.knees;
      case "Legs":
        return BodyPart.legs;
      case "LowerBack":
        return BodyPart.lowerBack;
      case "Neck":
        return BodyPart.neck;
      case "Obliques":
        return BodyPart.obliques;
      case "Pelvic":
        return BodyPart.pelvic;
      case "Psoas":
        return BodyPart.psoas;
      case "Quadriceps":
        return BodyPart.quadriceps;
      case "Shoulders":
        return BodyPart.shoulders;
      case "Spine":
        return BodyPart.spine;
      case "Thighs":
        return BodyPart.thighs;
      case "Triceps":
        return BodyPart.triceps;
      case "UpperBack":
        return BodyPart.upperBack;
      case "Wrists":
        return BodyPart.wrists;
      default:
        return BodyPart.none;
    }
  }

  String get article {
    switch (this) {
      case BodyPart.chest:
      case BodyPart.hip:
      case BodyPart.obliques:
      case BodyPart.shoulders:
      case BodyPart.spine:
        return "deiner";
      case BodyPart.ankles:
      case BodyPart.arms:
      case BodyPart.back:
      case BodyPart.biceps:
      case BodyPart.calves:
      case BodyPart.core:
      case BodyPart.elbows:
      case BodyPart.glutes:
      case BodyPart.hamstrings:
      case BodyPart.knees:
      case BodyPart.legs:
      case BodyPart.lowerBack:
      case BodyPart.neck:
      case BodyPart.pelvic:
      case BodyPart.psoas:
      case BodyPart.quadriceps:
      case BodyPart.thighs:
      case BodyPart.triceps:
      case BodyPart.upperBack:
      case BodyPart.wrists:
        return "deinem";

      case BodyPart.none:
        return "";
    }
  }

  /*TODO:
     Körperregionen sind nicht von Planfarbe anhängig.
     Es kann mehre Pläne mit unterschiedlichen Farben für eine Körperregion geben.
     Welche Farbe kommt die Körpreregion dann??
     Übergangslösung!
   */
  Color get color {
    switch (this) {
    // Brust / Schultern / Oberkörper (Koralle & Petrol)
      case BodyPart.chest:
        return PlanColors.koralle;
      case BodyPart.shoulders:
        return PlanColors.petrol;
    // Arme (Gold, Sand & Terrakotta)
      case BodyPart.arms:
      case BodyPart.biceps:
        return PlanColors.gold;
      case BodyPart.triceps:
      case BodyPart.elbows:
        return PlanColors.sand;
      case BodyPart.wrists:
        return PlanColors.terrakotta;
    // Rücken & Wirbelsäule (Marine & Petrol)
      case BodyPart.back:
      case BodyPart.upperBack:
        return PlanColors.marine;
      case BodyPart.lowerBack:
      case BodyPart.spine:
        return PlanColors.petrol;
    // Rumpf & Hals (Türkis & Lila)
      case BodyPart.core:
      case BodyPart.obliques:
        return PlanColors.tuerkis;
      case BodyPart.neck:
        return PlanColors.lila;
    // Becken & Hüfte (Lila & Terrakotta)
      case BodyPart.hip:
      case BodyPart.pelvic:
      case BodyPart.glutes:
      case BodyPart.psoas:
        return PlanColors.lila;
    // Beine / Oberschenkel / Unterschenkel (Olive & Türkis)
      case BodyPart.legs:
      case BodyPart.thighs:
      case BodyPart.quadriceps:
      case BodyPart.hamstrings:
        return PlanColors.olive;
      case BodyPart.calves:
      case BodyPart.knees:
      case BodyPart.ankles:
        return PlanColors.tuerkis;
      default:
        return Colors.transparent;
    }
  }
}