import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/models/weekly_ring.dart';
import 'package:app_prototype/data/repository/plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_prototype/core/theme/app_colors.dart';
import '../enum/goal.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository repo;

  PlanProvider(this.repo) {
    loadPlans();
  }

  List<Plan> _plans = [];
  List<Plan> get plans => _plans;
  List<Plan> get activePlans => _plans.where((p) => !p.archived).toList();
  Plan? _selectedPlan = null;
  Plan? get plan => _selectedPlan;

  List<BodyPart> _activeRegions = [];
  List<BodyPart> get activeRegions => _activeRegions;

  // haltet die aktuell generierte  Empfehlung im Arbeitsspeicher
  Plan? _recommendedPlan;
  Plan? get recommendedPlan => _recommendedPlan;
  // generiert eine Planempfehlung aus den  Übergebenen Übungen und benachrichtigt UI
  void generateRecommandedPlan(
      List<Exercise> exercises,
      BodyPart region,
      Goal goal,
      ) {
    _recommendedPlan = repo.createRecomendedPlan(
      exercises,
      region,
      goal,
    );
    notifyListeners();
  }

  Future<void> savePlan(Plan plan) async {
    await repo.savePlan(plan);
    _plans.add(plan);
    notifyListeners();
  }

  Future<Plan?> getPlan(String id) async {
    _selectedPlan = await repo.getPlanById(id);
    notifyListeners();
    return _selectedPlan ?? null;
  }

  Future<void> loadPlans() async {
    _plans = await repo.getAll();
    notifyListeners();
  }

  Future<void> updatePlanExercises(List<Exercise> exercises) async {
    if (_selectedPlan == null) return;
    final updatedPlan = _selectedPlan!.copyWith(exercises: exercises);
    await repo.savePlan(updatedPlan);
    _selectedPlan = updatedPlan;
    notifyListeners();
  }

  Future<List<BodyPart>> loadActiveTrainedRegions() async {
    _activeRegions = await repo.getActiveTrainedRegions();
    notifyListeners();
    return _activeRegions;
  }

  Future<void> incrementCompletedSessions(String planId) async {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      final currentPlan = _plans[index];
      final updatedPlan = currentPlan.copyWith(
        completedSessions: currentPlan.completedSessions + 1,
      );

      await repo.savePlan(updatedPlan);
      _plans[index] = updatedPlan;
      notifyListeners();
    }
  }

  /// Erstellt die Liste der konzentrischen Wochenringe für alle aktiven Pläne
  List<WeeklyRing> get weeklyRings {
    final active = activePlans;
    final List<WeeklyRing> rings = [];

    for (int i = 0; i < active.length; i++) {
      final plan = active[i];

      // Nimm die Farbe direkt vom Plan (mit Fallback auf eine Standardfarbe)
      final Color ringColor = plan.color ?? AppColors.sageDeep;

      rings.add(WeeklyRing(
        label: plan.name.isNotEmpty ? plan.name : plan.region.label,
        done: plan.completedSessions,
        goal: plan.sessionsPerWeek,
        color: ringColor,
      ));
    }

    return rings;
  }
}