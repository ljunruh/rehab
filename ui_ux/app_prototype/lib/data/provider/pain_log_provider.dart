import 'package:app_prototype/core/theme/app_theme.dart';
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

  /// Lädt alle Schmerzeinträge aus Isar
  Future<void> loadLogs() async {
    _allPainLogs = await _repository.getAllPainLogs();
    notifyListeners();
  }

  /// Fügt einen neuen Schmerzeintrag hinzu
  Future<void> addPainLog({
    required int level,
    required BodyPart region,
    required String note,
    required DateTime date,
  }) async {
    final entity = PainLog(
      level: level,
      region: region,
      note: note,
      date: date,
      dateKey: PainLog.keyOf(date),
    );

    await _repository.saveOrUpdatePainLog(entity);
    await loadLogs();
  }

  /// Holt alle Einträge von heute
  List<PainLog> get todayPainLogs {
    final todayKey = PainLog.keyOf(DateTime.now());
    return _allPainLogs.where((log) => log.dateKey == todayKey).toList();
  }

  // ── NEU: LOGIK FÜR DEN PAIN HISTORY CAROUSEL / GRAPH ───────────────────────

  /// Filtert und sortiert Einträge für eine bestimmte Region und ein spezifisches Monat/Jahr.
  List<PainLog> getLogsForRegionAndMonth(BodyPart region, int year, int month) {
    final list = _allPainLogs.where((e) {
      return e.region == region &&
          e.date.year == year &&
          e.date.month == month;
    }).toList();

    list.sort((a, b) => a.date.day.compareTo(b.date.day));
    return list;
  }

  //TODO: Prüfen ob die Schmerztrendberechnung so passt.
  /// Berechnet den Schmerztrend für eine Liste von Monats-Einträgen
  ({String text, Color bg, Color fg}) computeTrend(List<PainLog> entries) {
    if (entries.length < 2) {
      return (
      text: 'Noch nicht genug Daten für einen Trend.',
      bg: AppColors.offwhite,
      fg: AppColors.textSecondary,
      );
    }

    final firstHalf = entries.sublist(0, (entries.length / 2).ceil());
    final lastHalf = entries.sublist((entries.length / 2).floor());

    double avg(List<PainLog> xs) =>
        xs.map((e) => e.level).reduce((a, b) => a + b) / xs.length;

    final diff = avg(lastHalf) - avg(firstHalf);

    if (diff.abs() < 0.5) {
      return (
      text: 'Dein Schmerzlevel ist stabil geblieben.',
      bg: AppColors.offwhite,
      fg: AppColors.textSecondary,
      );
    }
    if (diff < 0) {
      return (
      text: 'Dein Schmerzlevel ist diesen Monat gesunken.',
      bg: AppColors.sageLight,
      fg: AppColors.sageDeep,
      );
    }
    if (diff >= 1.5) {
      return (
      text: 'Dein Schmerzlevel ist diesen Monat gestiegen.',
      bg: const Color(0xFFF2DCD0),
      fg: const Color(0xFF8B6353),
      );
    }
    return (
    text: 'Dein Schmerzlevel ist diesen Monat leicht gestiegen.',
    bg: const Color(0xFFF2DCD0),
    fg: const Color(0xFF8B6353),
    );
  }

  //TODO[API]: Test Schmerzgraph zu simulieren und Fake Daten dafür anzulegen
  /// Befüllt Isar mit Demo-Schmerzdaten und aktualisiert den Provider
  Future<void> seedDemoData() async {
    //await _repository.seedDemoPainLogs();
    await _repository.seedDemoPainLogs2();
    await loadLogs(); // Lädt alle Logs neu und benachrichtigt die Widgets (notifyListeners)
  }
}