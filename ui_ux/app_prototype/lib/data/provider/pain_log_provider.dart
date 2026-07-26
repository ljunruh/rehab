import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/pain_log.dart';
import 'package:app_prototype/data/repository/pain_log_repository.dart';
import 'package:flutter/material.dart';

class PainLogProvider extends ChangeNotifier {
  final PainLogRepository _repository;

  List<PainLog> _allPainLogs = [];
  List<PainLog> get allPainLogs => _allPainLogs;

  PainLogProvider(this._repository) {
    loadLogs();
  }

  /// Lädt alle Schmerzeinträge und bereitet sie für den Kalender vor
  Future<void> loadLogs() async {
    _allPainLogs = await _repository.getAllPainLogs();
    notifyListeners();
  }

  /// Fügt einen neuen Schmerzeintrag hinzu
  Future<void> addPainLog({
    required int level,
    required BodyPart region,
    required String note,
    required DateTime date
  }) async {

    // 1. Isar-Entität erstellen und befüllen
    final entity = PainLog(
      level: level,
      region: region,
      note: note,
      date: date,
      dateKey: PainLog.keyOf(date), // Erzeugt automatisch "YYYY-MM-DD"
    );

    // 2. Im Repository speichern
    await _repository.saveOrUpdatePainLog(entity);

    // 3. Lokalen State neu laden (aktualisiert die Listen und die Map automatisch)
    await loadLogs();
  }

  /// Holt alle Einträge von heute direkt aus der geladenen Liste
  List<PainLog> get todayPainLogs {
    final todayKey = PainLog.keyOf(DateTime.now());
    return _allPainLogs.where((log) => log.dateKey == todayKey).toList();
  }
}