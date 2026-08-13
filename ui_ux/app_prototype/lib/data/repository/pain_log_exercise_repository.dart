import 'package:app_prototype/data/models/api/pain_log_exercise.dart';
import 'package:isar/isar.dart';

class PainLogExerciseRepository {
  final Isar _isar;

  PainLogExerciseRepository(this._isar);

  /// Holt alle Schmerzeinträge aus Isar und sortiert sie nach Datum (neueste zuerst)
  Future<List<PainLogExercise>> getAllPainLogExercises() async {
    // Abfrage an Isar
    final entities = await _isar.painLogExercises.where().sortByDateDesc().findAll();

    // Mapping in das UI-Modell
    return entities.map((painLog) => PainLogExercise(
      level: painLog.level,
      region: painLog.region,
      date: painLog.date,
      dateKey: painLog.dateKey
    )).toList();
  }

  /// Speichert einen neuen Schmerzeintrag in der Isar-Datenbank
  Future<void> savePainLogExercise(PainLogExercise painLogExercise) async {
    await _isar.writeTxn(() async {
      await _isar.painLogExercises.put(painLogExercise);
    });
  }

  /// Optional: Holt Schmerzeinträge für eine ganz spezifische Übung
  Future<List<PainLogExercise>> getLogsForExercise(String exerciseId) async {
    final entities = await _isar.painLogExercises
        .where()
        .exerciseIdEqualTo(exerciseId)
        .sortByDateDesc()
        .findAll();

    return entities.map((entity) => PainLogExercise(
      level: entity.level,
      region: entity.region,
      date: entity.date,
      dateKey: entity.dateKey
    )).toList();
  }

  /// Löscht alle Schmerzeinträge, deren Datum im angegebenen Zeitraum liegt (inklusive Start- und Endtag).
  Future<void> deletePainLogExercisesBetween(DateTime fromDate, DateTime toDate) async {
    // Starttag ab 00:00:00 Uhr
    final startDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    // Endtag bis 23:59:59 Uhr
    final endDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59, 999);

    await _isar.writeTxn(() async {
      await _isar.painLogExercises
          .filter()
          .dateBetween(startDate, endDate)
          .deleteAll();
    });
  }
}