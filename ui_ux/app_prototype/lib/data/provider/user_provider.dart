import 'package:app_prototype/data/enum/gender.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:app_prototype/data/enum/body_part.dart'; // NEU: Import für dein bestehendes Ontologie-Enum
import 'package:app_prototype/data/models/models.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repo;

  User? _user;
  bool _loading = false;

  UserProvider(this.repo);

  User? get user => _user;
  bool get userExists => _user != null;
  bool get loading => _loading;

  String get fullName => _user?.name ?? '';

  String get email => _user?.email ?? '';

  String get ageText => _user != null ? '${_user!.age}' : '—';

  String get genderText => _user?.gender.label ?? '—';

  String get heightText => _user != null ? '${_user!.height} cm' : '—';

  String get weightText => _user != null ? '${_user!.weight} kg' : '—';

  String get skillLevelText => _user?.skillLevel.label ?? '—';

  /// Liest jegliche Bezeichner (Deutsch/Englisch/IDs) aus Isar/Ontologie,
  /// gleicht sie mit dem BodyPart-Enum ab und liefert saubere UI-Beschriftungen.
  List<String> get injuryLabels {
    if (_user == null || _user!.contraindications.isEmpty) return [];

    // Ein Set verhindert doppelte Anzeigen (z. B. wenn "Rumpf" und "Core" in der Liste stehen)
    final uniqueLabels = <String>{};

    for (final rawInjury in _user!.contraindications) {
      final clean = rawInjury.trim().toLowerCase();

      // 1. Sonderfall für Gleichgewicht (kein direkter Muskel / BodyPart im klassischen Sinn)
      if (clean.contains('gleichgewicht') || clean.contains('balance')) {
        uniqueLabels.add('Gleichgewichtsprobleme');
        continue;
      }

      // 2. String normalisieren (Zusätze wie "Issue", "Weakness", "Beschwerden" abschneiden)
      final normalizedInput = clean
          .replaceAll('issue', '')
          .replaceAll('weakness', '')
          .replaceAll('beschwerden', '')
          .replaceAll('probleme', '')
          .replaceAll('schwäche', '')
          .replaceAll('schwaeche', '')
          .replaceAll('schmerzen im', '')
          .replaceAll('schmerzen', '')
          .trim();

      // 3. Über das bestehende BodyPart-Enum aus body_part.dart iterieren (vollkommen dynamisch)
      BodyPart matchedPart = BodyPart.none;
      for (final part in BodyPart.values) {
        if (part.name.toLowerCase() == normalizedInput ||
            part.label.toLowerCase() == normalizedInput ||
            part.labelEN.toLowerCase() == normalizedInput) {
          matchedPart = part;
          break;
        }
      }

      // 4. Teil-Abgleich-Fallback, falls Bezeichnungen zusammengesetzt oder ungenau sind
      if (matchedPart == BodyPart.none) {
        if (clean.contains('rumpf') || clean.contains('core')) {
          matchedPart = BodyPart.core;
        } else if (clean.contains('unterer rücken') || clean.contains('lowerback')) {
          matchedPart = BodyPart.lowerBack;
        } else if (clean.contains('oberer rücken') || clean.contains('upperback')) {
          matchedPart = BodyPart.upperBack;
        } else if (clean.contains('rücken') || clean.contains('back')) {
          matchedPart = BodyPart.back;
        } else if (clean.contains('wirbelsäule') || clean.contains('spine')) {
          matchedPart = BodyPart.spine;
        } else if (clean.contains('handgelenk') || clean.contains('wrist')) {
          matchedPart = BodyPart.wrists;
        } else if (clean.contains('schulter') || clean.contains('shoulder')) {
          matchedPart = BodyPart.shoulders;
        } else if (clean.contains('knie') || clean.contains('knee')) {
          matchedPart = BodyPart.knees;
        } else if (clean.contains('hamstring') || clean.contains('oberschenkelrückseite')) {
          matchedPart = BodyPart.hamstrings;
        } else if (clean.contains('hüfte') || clean.contains('huefte') || clean.contains('hip')) {
          matchedPart = BodyPart.hip;
        } else if (clean.contains('nacken') || clean.contains('neck')) {
          matchedPart = BodyPart.neck;
        } else if (clean.contains('sprunggelenk') || clean.contains('ankle')) {
          matchedPart = BodyPart.ankles;
        } else if (clean.contains('gesäß') || clean.contains('glute')) {
          matchedPart = BodyPart.glutes;
        }
      }

      // 5. In das gewünschte deutsche UI-Label übersetzen
      if (matchedPart != BodyPart.none) {
        uniqueLabels.add(_mapBodyPartToUiLabel(matchedPart));
      } else if (rawInjury.isNotEmpty) {
        // Fallback für ungemappte Strings aus der Ontologie
        uniqueLabels.add(rawInjury);
      }
    }

    return uniqueLabels.toList();
  }

  /// Interne Hilfsmethode zur Ermittlung des passenden UI-Textes basierend auf BodyPart.
  String _mapBodyPartToUiLabel(BodyPart part) {
    switch (part) {
      case BodyPart.ankles:
        return "Sprunggelenksbeschwerden";
      case BodyPart.core:
        return "Rumpfschwäche";
      case BodyPart.hip:
        return "Hüftbeschwerden";
      case BodyPart.knees:
        return "Kniebeschwerden";
      case BodyPart.neck:
        return "Nackenbeschwerden";
      case BodyPart.lowerBack:
        return "Schmerzen im unteren Rücken";
      case BodyPart.upperBack:
        return "Schmerzen im oberen Rücken";
      case BodyPart.spine:
        return "Wirbelsäulenprobleme";
      case BodyPart.wrists:
        return "Handgelenksbeschwerden";
      case BodyPart.shoulders:
        return "Schulterbeschwerden";
      case BodyPart.hamstrings:
        return "Oberschenkelrückseite-Beschwerden (Hamstrings)";
      case BodyPart.glutes:
        return "Gesäßbeschwerden";
      default:
      // Nutzt die bestehende Extension aus deiner unveränderten body_part.dart
        return part.label;
    }
  }

  String get initials {
    final name = _user?.name ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> init() async {
    _loading = true;
    notifyListeners();

    _user = await repo.getUser();

    _loading = false;
    notifyListeners();
  }

  Future<void> saveUser({
    required String name,
    required Gender gender,
    required int age,
    required int height,
    required int weight,
    required SkillLevel skillLevel,
    required List<String> contraindications,
    required List<String> joints,
  }) async {
    final newUser = User(
      name: name,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      skillLevel: skillLevel,
      contraindications: contraindications,
        joints: joints
    );

    await repo.saveUser(newUser);

    _user = newUser;
    notifyListeners();
  }

  Future<void> deleteUser() async {
    await repo.deleteUser();
    _user = null;
    notifyListeners();
  }
}