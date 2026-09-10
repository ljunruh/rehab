import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:isar/isar.dart';

class PlanRepository {
  final Isar isar;

  PlanRepository(this.isar);

  Future<List<Plan>> getAll() async => isar.plans.where().findAll();

  Future<Plan?> getPlan(Plan plan) async => isar.plans.getById(plan.id);

  Future<Plan?> getPlanById(String id) async =>
      isar.plans.where().idEqualTo(id).findFirst();

  Future<void> savePlan(Plan plan) async {
    await isar.writeTxn(() async {
      await isar.plans.put(plan);
    });
  }

  Future<void> deletePlan(Plan plan) async {
    await isar.writeTxn(() async {
      await isar.plans.deleteById(plan.id);
    });
  }

  Future<List<Plan>> getActivePlans() async {
    return isar.plans.filter().archivedEqualTo(false).findAll();
  }

  Future<List<BodyPart>> getActiveTrainedRegions() async {
    final activePlans =
    await isar.plans.filter().archivedEqualTo(false).findAll();

    // Regionen extrahieren und Duplikate entfernen
    return activePlans.map((plan) => plan.region).toSet().toList();
  }

  /// Setzt completedSessions aller aktiven (nicht archivierten) Pläne in einer Transaktion auf 0
  Future<void> resetAllActivePlansCompletedSessions() async {
    await isar.writeTxn(() async {
      final activePlans =
      await isar.plans.filter().archivedEqualTo(false).findAll();

      for (final plan in activePlans) {
        if (plan.completedSessions > 0) {
          final updatedPlan = plan.copyWith(completedSessions: 0);
          await isar.plans.put(updatedPlan);
        }
      }
    });
  }

  /// Generiert aus einer Liste von Übungen zufällig eine Planempfehlung (max 3 Übungen)
  Plan createRecomendedPlan(
      List<Exercise> exercises,
      BodyPart region,
      Goal goal,
      ) {
    final shuffled = List<Exercise>.from(exercises)..shuffle();
    final selection = shuffled.take(3).toList();

    return Plan(
      id: 'Plan_recomended_${DateTime.now().millisecondsSinceEpoch}',
      name: '${region.label}-Plan(empfohlen)',
      region: region,
      goals: [goal],
      exercises: selection,
      sessionsPerWeek: 3,
      source: 'empfohlen',
    );
  }
}