import 'package:app_prototype/data/models/graph/plan.dart';
import 'package:app_prototype/data/service/plan_service.dart';

class PlanRepository {
  final PlanService service;

  PlanRepository({required this.service});

  Future<Plan?> getPlan(Plan plan) => service.getPlan(plan);

  Future<void> savePlan(Plan plan) => service.savePlan(plan);

  Future<void> deletePlan(Plan plan) => service.deletePlan(plan);
}