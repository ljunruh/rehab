import 'package:app_prototype/data/models/graph/condition.dart';
import 'package:isar/isar.dart';

class ConditionService {
  final Isar isar;

  ConditionService(this.isar);

  Future<List<Condition>> getAll() {
    return isar.conditions.where().findAll();
  }

  Future<void> saveAll(List<Condition> list) async {
    await isar.writeTxn(() async {
      await isar.conditions.clear();
      await isar.conditions.putAll(list);
    });
  }
}