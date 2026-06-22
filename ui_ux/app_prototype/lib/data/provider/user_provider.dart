import 'package:app_prototype/data/model/enum/gender.dart';
import 'package:app_prototype/data/model/user.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:flutter/material.dart';
import '../model/condition.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repo;

  UserProvider(this.repo);

  User? user;
  List<Condition> conditions = [];

  bool loading = false;
  bool get userExists => user != null;

  // ---------------------------
  // COMPUTED UI FIELDS
  // ---------------------------
  String get fullName => user?.name ?? '';

  String get email => user?.email ?? '';

  String get ageText => user?.age != null ? '${user!.age}' : '—';

  String get genderText => user?.gender.label ?? '—';

  String get heightText =>
      user != null ? '${user!.height.toInt()} cm' : '—';

  String get weightText =>
      user != null ? '${user!.weight.toInt()} kg' : '—';

  String get initials {
    final name = user?.name ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  List<String> get conditionLabels {
    if (user == null) return [];

    return user!.conditions.map((id) {
      final match = conditions.firstWhere(
            (c) => c.id == id,
        orElse: () => Condition(id: id, label: id, comment: ''),
      );
      return match.label;
    }).toList();
  }

  // ---------------------------
  // LOGIC
  // ---------------------------
  Future<void> init() async {
    loading = true;
    notifyListeners();

    user = await repo.getUser();
    conditions = await repo.getConditions();

    loading = false;
    notifyListeners();
  }

  Future<void> saveUser(User user) async {
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