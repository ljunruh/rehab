import 'package:app_prototype/data/models/api/plan.dart';
import 'package:isar/isar.dart';

class PlanRepository {
  final Isar isar;

  PlanRepository(this.isar);

  Future<List<Plan>> getAll() async => isar.plans.where().findAll();

  Future<Plan?> getPlan(Plan plan) async => isar.plans.get(plan.isarId);

  Future<Plan?> getPlanById(String id) async => isar.plans.where().idEqualTo(id).findFirst();

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

  Future<List<String>> getActiveTrainedRegions() async {
    final activePlans = await isar.plans
        .filter()
        .archivedEqualTo(false)
        .findAll();

    // Regionen extrahieren und Duplikate entfernen
    return activePlans.map((plan) => plan.region).toSet().toList();
  }
}