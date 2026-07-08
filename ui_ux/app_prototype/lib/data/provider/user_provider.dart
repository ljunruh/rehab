import 'package:app_prototype/data/enum/gender.dart';
import 'package:app_prototype/data/enum/contraindication.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
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

  List<String> get injuryLabels =>
      _user?.contraindication
          .map((name) => InjuryExt.fromString(name).label)
          .toList() ??
          [];

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
    required List<String> injuries,
  }) async {
    final newUser = User(
      name: name,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      skillLevel: skillLevel,
      contraindication: injuries,
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