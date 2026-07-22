import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:isar/isar.dart';

class PlanRepository {
  final Isar isar;

  PlanRepository(this.isar);

  Future<List<Plan>> getAll() async => isar.plans.where().findAll();

  Future<Plan?> getPlan(Plan plan) async => isar.plans.getById(plan.id);

  Future<Plan?> getPlanById(String id) async => isar.plans.where().idEqualTo(id).findFirst();

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
    final activePlans = await isar.plans
        .filter()
        .archivedEqualTo(false)
        .findAll();

    // Regionen extrahieren und Duplikate entfernen
    return activePlans.map((plan) => plan.region).toSet().toList();
  }
}