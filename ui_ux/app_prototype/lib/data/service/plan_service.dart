import 'package:app_prototype/data/models/graph/plan.dart';
import 'package:isar/isar.dart';

class PlanService {
  final Isar isar;

  PlanService(this.isar);

  Future<List<Plan>> getAll() async => isar.plans.where().findAll();

  Future<Plan?> getPlan(Plan plan) async => isar.plans.get(plan.isarId);

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
}