import 'package:app_prototype/data/models/condition.dart';
import 'package:isar/isar.dart';

class ConditionLocalDataSource {
  final Isar isar;

  ConditionLocalDataSource(this.isar);

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