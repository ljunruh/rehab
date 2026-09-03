import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/app_state.dart';
import 'package:app_prototype/data/models/weekly_ring.dart';
import 'package:app_prototype/data/repository/app_state_repository.dart';
import 'package:app_prototype/data/repository/plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_prototype/core/theme/app_colors.dart';
import '../enum/goal.dart';
import '../models/api/api_models.dart';

class PlanProvider extends ChangeNotifier with WidgetsBindingObserver {
  final PlanRepository planRepo;
  final AppStateRepository appStateRepo;

  PlanProvider({
    required this.planRepo,
    required this.appStateRepo,
  }) {
    _init();
    // Registriere den Observer beim Erstellen
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _init() async {
    await loadPlans();
    await checkAndResetWeeklySessionsIfNeeded();
  }

  @override
  void dispose() {
    // Observer wieder entfernen, wenn der Provider zerstört wird
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Diese Methode wird von Flutter automatisch aufgerufen, wenn sich der App-Zustand ändert
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App kommt wieder in den Vordergrund -> Reset prüfen!
      checkAndResetWeeklySessionsIfNeeded();
    }
  }

  List<Plan> _plans = [];
  List<Plan> get plans => _plans;
  List<Plan> get activePlans => _plans.where((p) => !p.archived).toList();
  Plan? _selectedPlan;
  Plan? get plan => _selectedPlan;

  List<BodyPart> _activeRegions = [];
  List<BodyPart> get activeRegions => _activeRegions;

  // Hält die aktuell generierte Empfehlung im Arbeitsspeicher
  Plan? _recommendedPlan;
  Plan? get recommendedPlan => _recommendedPlan;

  // Generiert eine Planempfehlung aus den übergebenen Übungen und benachrichtigt UI
  void generateRecommandedPlan(
      List<Exercise> exercises,
      BodyPart region,
      Goal goal,
      ) {
    _recommendedPlan = planRepo.createRecomendedPlan(exercises, region, goal);
    notifyListeners();
  }

  Future<void> savePlan(Plan plan) async {
    await planRepo.savePlan(plan);
    _plans.add(plan);
    notifyListeners();
  }

  Future<Plan?> getPlan(String id) async {
    _selectedPlan = await planRepo.getPlanById(id);
    notifyListeners();
    return _selectedPlan;
  }

  Future<void> loadPlans() async {
    _plans = await planRepo.getAll();
    notifyListeners();
  }

  Future<void> updatePlanExercises(List<Exercise> exercises) async {
    if (_selectedPlan == null) return;
    final updatedPlan = _selectedPlan!.copyWith(exercises: exercises);
    await planRepo.savePlan(updatedPlan);
    _selectedPlan = updatedPlan;

    final index = _plans.indexWhere((p) => p.id == updatedPlan.id);
    if (index != -1) {
      _plans[index] = updatedPlan;
    }

    notifyListeners();
  }

  // Plan komplett aus Isar löschen
  Future<void> deletePlan(String planId) async {
    final planToDelete = await planRepo.getPlanById(planId);
    if (planToDelete != null) {
      await planRepo.deletePlan(planToDelete);
      _plans.removeWhere((p) => p.id == planId);
      if (_selectedPlan?.id == planId) {
        _selectedPlan = null;
      }
      notifyListeners();
    }
  }

  // Plan archivieren und de-archivieren
  Future<void> archivePlan(String planId, {bool archive = true}) async {
    final planToArchive = await planRepo.getPlanById(planId);

    if (planToArchive != null) {
      final updatedPlan = planToArchive.copyWith(archived: archive);
      await planRepo.savePlan(updatedPlan);

      final index = _plans.indexWhere((p) => p.id == planId);
      if (index != -1) {
        _plans[index] = updatedPlan;
      }
      if (_selectedPlan?.id == planId) {
        _selectedPlan = updatedPlan;
      }
      notifyListeners();
    }
  }

  // Kalenderfarbe eines Plans ändern (in Isar speichern)
  Future<void> updatePlanColor(String planId, Color color) async {
    final planToUpdate = await planRepo.getPlanById(planId);

    if (planToUpdate != null) {
      final updatedPlan = planToUpdate.copyWith(color: color);
      await planRepo.savePlan(updatedPlan);
      final index = _plans.indexWhere((p) => p.id == planId);
      if (index != -1) {
        _plans[index] = updatedPlan;
      }
      if (_selectedPlan?.id == planId) {
        _selectedPlan = updatedPlan;
      }
      notifyListeners();
    }
  }

  // Neue Übungen zum Plan hinzufügen (in Isar speichern)
  Future<void> addExercisesToPlan(
      String planId,
      List<Exercise> newExercises,
      ) async {
    final targetPlan = await planRepo.getPlanById(planId);
    if (targetPlan != null) {
      final updatedList = List<Exercise>.from(targetPlan.exercises)
        ..addAll(newExercises);

      final updatedPlan = targetPlan.copyWith(exercises: updatedList);
      await planRepo.savePlan(updatedPlan);

      final index = _plans.indexWhere((p) => p.id == planId);
      if (index != -1) {
        _plans[index] = updatedPlan;
      }
      if (_selectedPlan?.id == planId) {
        _selectedPlan = updatedPlan;
      }
      notifyListeners();
    }
  }

  Future<List<BodyPart>> loadActiveTrainedRegions() async {
    _activeRegions = await planRepo.getActiveTrainedRegions();
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

      await planRepo.savePlan(updatedPlan);
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

      final Color ringColor = plan.color ?? AppColors.sageDeep;

      rings.add(
        WeeklyRing(
          label: plan.name.isNotEmpty ? plan.name : plan.region.label,
          done: plan.completedSessions,
          goal: plan.sessionsPerWeek,
          color: ringColor,
        ),
      );
    }

    return rings;
  }

  /// Berechnet den Montag 00:00:00 Uhr der Woche des übergebenen Datums
  DateTime getMondayOfWeek(DateTime date) {
    final mondayDate = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 0, 0, 0);
  }

  /// Prüft, ob der Schwellenwert (Montag 00:00) erreicht/überschritten ist und setzt Pläne zurück
  Future<void> checkAndResetWeeklySessionsIfNeeded() async {
    final now = DateTime.now();

    // 1. Gespeicherten AppState über das AppStateRepository laden
    AppState? appState = await appStateRepo.getAppState();

    // Erster App-Start überhaupt: Setze den nächsten Ziel-Montag 00:00 Uhr
    if (appState == null) {
      final currentMonday = getMondayOfWeek(now);
      final nextMonday = currentMonday.add(const Duration(days: 7));

      await appStateRepo.saveAppState(AppState(nextResetDate: nextMonday));
      return;
    }

    // 2. Prüfen: Ist die aktuelle Zeit >= dem Ziel-Montag 00:00 Uhr?
    if (now.isAfter(appState.nextResetDate) ||
        now.isAtSameMomentAs(appState.nextResetDate)) {

      // Pläne in Isar über das PlanRepository zurücksetzen
      await planRepo.resetAllActivePlansCompletedSessions();

      // Lokale Liste aktualisieren
      _plans = await planRepo.getAll();

      if (_selectedPlan != null && !_selectedPlan!.archived) {
        _selectedPlan = _selectedPlan!.copyWith(completedSessions: 0);
      }

      // 3. Nächsten Ziel-Montag berechnen und in Isar sichern
      final currentMonday = getMondayOfWeek(now);
      final newNextMonday = currentMonday.add(const Duration(days: 7));

      appState.nextResetDate = newNextMonday;
      await appStateRepo.saveAppState(appState);

      notifyListeners();
    }
  }

  /// Aktualisiert die completedSessions aller aktiven Pläne anhand der übergebenen Map
  Future<void> updateCompletedSessionsFromMap(Map<String, int> updatedSessionsMap) async {
    for (int i = 0; i < _plans.length; i++) {
      final plan = _plans[i];
      if (updatedSessionsMap.containsKey(plan.id)) {
        final newCount = updatedSessionsMap[plan.id]!;
        if (plan.completedSessions != newCount) {
          final updatedPlan = plan.copyWith(completedSessions: newCount);
          await planRepo.savePlan(updatedPlan);
          _plans[i] = updatedPlan;
        }
      }
    }
    notifyListeners();
  }
}
