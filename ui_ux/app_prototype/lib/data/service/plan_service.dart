import 'package:app_prototype/data/models/api/plan.dart';
import 'package:isar/isar.dart';
import 'package:app_prototype/data/models/api/exercise.dart';

import '../models/api/exercise.dart';

class PlanService {
  final Isar isar;

  PlanService(this.isar);

  Future<List<Plan>> getAll() async => isar.plans.where().findAll();

  Future<Plan?> getPlan(Plan plan) async => isar.plans.get(plan.isarId);

  Future<Plan?> getPlanById(String id) async =>
      isar.plans.where().idEqualTo(id).findFirst();

  Future<void> savePlan(Plan plan) async {
    await isar.writeTxn(() async {
      await isar.plans.put(plan);
    });
  }

  Future<void> deletePlan(Plan plan) async {
    await isar.writeTxn(() async {
      await isar.plans.delete(plan.isarId);
    });
  }

  ///  generiert aus einer liste von übungen  zufällige eine  planempfelung (max 3 übungen )
  Plan createRecomendedPlan(
    List<Exercise> exercises,
    String region,
    String goal,
  ) {
    // Erstellt eine kopie der liste und mische sie zufällig  durch (Random)
    final shuffled = List<Exercise>.from(exercises)..shuffle();
    // wählt dann die ersten 3 übungen aus
    final selection = shuffled.take(3).toList();

    // erstellt das Plan_objekt mit der kennzeichnung "Empfohlen"
    return Plan(
      id: 'Plan_recomended_${DateTime.now().millisecondsSinceEpoch}',
      name: '$region-Plan(empfohlen)',
      region: region,
      goal: goal,
      exercises: selection,
      sessionsPerWeek: 3,
      source: 'empfohlen',
    );
  }
}
