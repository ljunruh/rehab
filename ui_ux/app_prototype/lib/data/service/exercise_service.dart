import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:isar/isar.dart';

class ExerciseService {
  /* TODO[API]: Hier wahrscheinlich kein Isar notwendig sondern nur Filter funktionen
  final Isar isar;

  ExerciseService(this.isar);

  Future<List<Exercise>> getAll() {
    return isar.exercises.where().findAll();
  }

  Future<void> saveAll(List<Exercise> list) async {
    await isar.writeTxn(() async {
      await isar.exercises.clear();
      await isar.exercises.putAll(list);
    });
  }
  */
}