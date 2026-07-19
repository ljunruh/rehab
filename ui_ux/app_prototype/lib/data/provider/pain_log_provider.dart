import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/pain_log.dart';
import 'package:app_prototype/data/repository/pain_log_repository.dart';
import 'package:flutter/material.dart';

class PainLogProvider extends ChangeNotifier {
  final PainLogRepository _repository;

  // Interne States
  List<PainLog> _allPainLogs = [];
  Map<String, List<PainLog>> _logsByDay = {};
  bool _isLoading = false;

  // Getter für die UI
  List<PainLog> get allPainLogs => _allPainLogs;
  Map<String, List<PainLog>> get logsByDay => _logsByDay;
  bool get isLoading => _isLoading;

  PainLogProvider(this._repository) {
    // Automatisch beim Erstellen des Providers die Daten laden
    loadLogs();
  }

  /// Lädt alle Schmerzeinträge und bereitet sie für den Kalender vor
  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPainLogs = await _repository.getAllPainLogs();

      // Gruppierung nach dem Datumsschlüssel (dateKey) vornehmen
      final Map<String, List<PainLog>> grouped = {};
      for (var log in _allPainLogs) {
        grouped.putIfAbsent(log.dateKey, () => []).add(log);
      }

      _logsByDay = grouped;
    } catch (e) {
      debugPrint("Fehler beim Laden der PainLogs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fügt einen neuen Schmerzeintrag hinzu
  Future<void> addPainLog({
    required int level,
    required BodyPart region,
    required String note,
    required DateTime date
  }) async {
    final dateKey = PainLog.keyOf(date);
    final existingLog = await _repository.findLogByDateAndRegion(dateKey, region);

    // 1. Isar-Entität erstellen und befüllen
    final entity = PainLog(
      level: level,
      region: region,
      note: note,
      date: date,
      dateKey: dateKey, // Erzeugt automatisch "YYYY-MM-DD"
    );

    // 2. Im Repository speichern
    await _repository.saveOrUpdatePainLog(entity);

    // 3. Lokalen State neu laden (aktualisiert die Listen und die Map automatisch)
    await loadLogs();
  }
}