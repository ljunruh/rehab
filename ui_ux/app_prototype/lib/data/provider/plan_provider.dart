import 'package:app_prototype/data/models/graph/plan.dart';
import 'package:app_prototype/data/repository/plan_repository.dart';
import 'package:flutter/material.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository repo;

  PlanProvider(this.repo) {
    loadPlans();
  }

  List<Plan> _plans = [];
  List<Plan> get plans => _plans;

  Future<void> savePlan(Plan plan) async {
    await repo.savePlan(plan);
    _plans.add(plan);
    notifyListeners();
  }

  Future<void> loadPlans() async {
    _plans = await repo.getAll();
    notifyListeners();
  }
}