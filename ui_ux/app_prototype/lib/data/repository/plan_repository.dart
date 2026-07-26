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

  ///  generiert aus einer liste von übungen  zufällige eine  planempfelung (max 3 übungen )
  Plan createRecomendedPlan(
    List<Exercise> exercises,
    BodyPart region,
    Goal goal,
  ) {
    // Erstellt eine kopie der liste und mische sie zufällig  durch (Random)
    final shuffled = List<Exercise>.from(exercises)..shuffle();
    // wählt dann die ersten 3 übungen aus
    final selection = shuffled.take(3).toList();

    // erstellt das Plan_objekt mit der kennzeichnung "Empfohlen"
    return Plan(
      id: 'Plan_recomended_${DateTime.now().millisecondsSinceEpoch}',
      name: '${region.label}-Plan(empfohlen)',
      region: region,
      goal: goal,
      exercises: selection,
      sessionsPerWeek: 3,
      source: 'empfohlen',
    );
  }
}