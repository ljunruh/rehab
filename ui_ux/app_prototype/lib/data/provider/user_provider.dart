import 'package:app_prototype/data/enum/gender.dart';
import 'package:app_prototype/data/enum/injury.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:app_prototype/data/models/models.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repo;
  User? user;
  bool loading = false;
  bool get userExists => user != null;

  UserProvider(this.repo);

  // ---------------------------
  // COMPUTED UI FIELDS
  // ---------------------------
  String get fullName => user?.name ?? '';

  String get email => user?.email ?? '';

  String get ageText => user?.age != null ? '${user!.age}' : '—';

  String get genderText => user?.gender.label ?? '—';

  String get heightText =>
      user != null ? '${user!.height} cm' : '—';

  String get weightText =>
      user != null ? '${user!.weight} kg' : '—';

  String get skillLevelText => user?.skillLevel.label ?? '—';

  List<String> get injuryLabels =>
      user?.injuries.map((name) => InjuryExt.fromString(name).label).toList() ?? [];

  String get initials {
    final name = user?.name ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  // ---------------------------
  // LOGIC
  // ---------------------------
  Future<void> init() async {
    loading = true;
    notifyListeners();

    user = await repo.getUser();

    loading = false;
    notifyListeners();
  }

  Future<void> saveUser(User user) async {
    await repo.saveUser(user);
    this.user = user;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    await repo.saveUser(user);
    this.user = user;
    notifyListeners();
  }

  Future<void> deleteUser() async {
    await repo.deleteUser();
    this.user = null;
    notifyListeners();
  }
}