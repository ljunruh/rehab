import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/pain_log.dart';
import 'package:isar/isar.dart';

class PainLogRepository {
  final Isar _isar;

  PainLogRepository(this._isar);

  /// Holt alle Schmerzeinträge aus Isar und sortiert sie nach Datum (neueste zuerst)
  Future<List<PainLog>> getAllPainLogs() async {
    // Abfrage an Isar
    final entities = await _isar.painLogs.where().sortByDateDesc().findAll();

    // Mapping in das UI-Modell
    return entities.map((painLog) => PainLog(
      level: painLog.level,
      region: painLog.region,
      note: painLog.note,
      date: painLog.date,
      dateKey: painLog.dateKey
    )).toList();
  }

  /// Speichert oder aktualisiert einen Schmerzeintrag in der Isar-Datenbank
  Future<void> saveOrUpdatePainLog(PainLog newLog) async {
    final existingLog = await _isar.painLogs
        .filter()
        .dateKeyEqualTo(newLog.dateKey)
        .regionEqualTo(newLog.region)
        .findFirst();

    if (existingLog != null) {
      newLog.id = existingLog.id;
    }

    await _isar.writeTxn(() async {
      await _isar.painLogs.put(newLog);
    });
  }

  /// Sucht nach einem existierenden Eintrag für ein bestimmtes Datum und eine Region
  Future<PainLog?> findLogByDateAndRegion(String dateKey, BodyPart region) async {
    return await _isar.painLogs
        .filter()
        .dateKeyEqualTo(dateKey)
        .regionEqualTo(region)
        .findFirst(); // Liefert den Eintrag, falls er existiert, sonst null
  }

  /// Optional: Holt Schmerzeinträge für eine ganz spezifische Übung
  Future<List<PainLog>> getLogsForExercise(String exerciseId) async {
    final entities = await _isar.painLogs
        .where()
        //.exerciseIdEqualTo(exerciseId)
        .sortByDateDesc()
        .findAll();

    return entities.map((entity) => PainLog(
      level: entity.level,
      region: entity.region,
      note: entity.note,
      date: entity.date,
      dateKey: entity.dateKey
    )).toList();
  }
}