import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/pain_log_exercise.dart';
import 'package:app_prototype/data/repository/pain_log_exercise_repository.dart';
import 'package:flutter/material.dart';

class PainLogExerciseProvider extends ChangeNotifier {
  final PainLogExerciseRepository _repository;

  // Interne States
  List<PainLogExercise> _allPainLogs = [];
  Map<String, List<PainLogExercise>> _logsByDay = {};
  bool _isLoading = false;

  // Getter für die UI
  List<PainLogExercise> get allPainLogs => _allPainLogs;
  Map<String, List<PainLogExercise>> get logsByDay => _logsByDay;
  bool get isLoading => _isLoading;

  PainLogExerciseProvider(this._repository) {
    // Automatisch beim Erstellen des Providers die Daten laden
    loadLogs();
  }

  /// Lädt alle Schmerzeinträge und bereitet sie für den Kalender vor
  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPainLogs = await _repository.getAllPainLogExercises();

      // Gruppierung nach dem Datumsschlüssel (dateKey) vornehmen
      final Map<String, List<PainLogExercise>> grouped = {};
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
    required DateTime date,
    required String? planId,
    required String? exerciseId,
  }) async {
    final entity = PainLogExercise(
      level: level,
      region: region,
      date: date,
      dateKey: PainLogExercise.keyOf(date), // Erzeugt automatisch "YYYY-MM-DD"
      planId: planId,
      exerciseId: exerciseId,
    );

    // 2. Im Repository speichern
    await _repository.savePainLogExercise(entity);

    // 3. Lokalen State neu laden (aktualisiert die Listen und die Map automatisch)
    await loadLogs();
  }

  /// Löscht Schmerzeinträge im gewählten Zeitraum und aktualisiert die UI.
  Future<void> deleteLogsBetween(DateTime fromDate, DateTime toDate) async {
    await _repository.deletePainLogExercisesBetween(fromDate, toDate);
    await loadLogs(); // Lädt die Daten neu und ruft notifyListeners() auf
  }
}