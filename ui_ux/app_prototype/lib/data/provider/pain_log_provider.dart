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
  /// Berechnet den Schmerz-Trend für eine Liste von Einträgen innerhalb eines Monats.
  ///
  /// **Methodik:**
  /// 1. **Lineare Regression (Kleinste-Quadrate-Methode):**
  ///    Berechnet die Steigung der Ausgleichsgeraden über alle Datenpunkte des Monats.
  ///    Dadurch werden zeitliche Abstände exakt berücksichtigt und vereinzelte
  ///    Ausreißer schwächen sich gegenseitig ab.
  ///
  /// 2. **Klinische Relevanz (MCID - Minimal Clinically Important Difference):**
  ///    Reine mathematische Minischwankungen werden herausgefiltert. Ein Trend wird
  ///    erst ausgewiesen, wenn die hochgerechnete Veränderung im Monat mindestens
  ///    **0.8 Punkte** auf der 1–10 Skala ausmacht.
  ///
  /// **Rückgabewert:**
  /// - `null`: Bei zu wenigen Daten (< 3 Einträge) oder wenn keine relevante
  ///   Veränderung vorliegt (stabil/Schwankung unter Schwellenwert).
  /// - `({String text, Color bg, Color fg})`: Record mit UI-Styling bei signifikantem
  ///   Trend (sinkend oder steigend).
  ({String text, Color bg, Color fg})? computeTrend(List<PainLog> entries) {
    // Mindestens 3 Datenpunkte nötig, um eine verlässliche Trendlinie zu ziehen
    if (entries.length < 3) return null;

    // --- 1. Vorbereitung für die Lineare Regression (y = m * x + b) ---
    double sumX = 0;   // Summe aller Monatstage (x-Werte)
    double sumY = 0;   // Summe aller Schmerzlevel (y-Werte)
    double sumXY = 0;  // Summe aus (x * y)
    double sumX2 = 0;  // Summe aus (x^2)
    final n = entries.length;

    for (int i = 0; i < n; i++) {
      // x = Tag des Monats (1..31), y = Schmerzintensität (1..10)
      final x = entries[i].date.day.toDouble();
      final y = entries[i].level.toDouble();

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    // --- 2. Steigung (m) der Ausgleichsgeraden berechnen ---
    // Formel: m = (n * ∑(xy) - ∑x * ∑y) / (n * ∑(x²) - (∑x)²)
    final denominator = (n * sumX2 - sumX * sumX);
    if (denominator == 0) return null; // Verhindert Division durch 0 (z.B. alle Logs am selben Tag)

    final slope = (n * sumXY - sumX * sumY) / denominator;

    // --- 3. Hochrechnung der Gesamtveränderung über einen Monat (30 Tage) ---
    final totalChange = slope * 30;

    // --- 4. Auswertung mit Schwellenwert für klinische Relevanz (MCID = 0.8) ---
    if (totalChange <= -0.8) {
      // Schmerzlevel sinkt spürbar
      return (
      text: 'Dein Schmerzlevel zeigt einen sinkenden Trend.',
      bg: AppColors.sageLight,
      fg: AppColors.sageDeep,
      );
    } else if (totalChange >= 0.8) {
      // Schmerzlevel steigt spürbar
      return (
      text: 'Dein Schmerzlevel zeigt einen steigenden Trend.',
      bg: const Color(0xFFF2DCD0),
      fg: const Color(0xFF8B6353),
      );
    }

    // Veränderung liegt unter 0.8 Punkten -> gilt als stabil / kein Banner
    return null;
  }

  /// Liefert alle Schmerzeinträge für ein bestimmtes Datum (Format: YYYY-MM-DD).
  List<PainLog> getLogsForDateKey(String dateKey) {
    return _allPainLogs.where((log) => log.dateKey == dateKey).toList();
  }

  /// Liefert alle Schmerzeinträge für ein bestimmtes Jahr und Monat.
  List<PainLog> getLogsForMonth(int year, int month) {
    return _allPainLogs.where((log) => log.date.year == year && log.date.month == month).toList();
  }

  /// Löscht Schmerzeinträge im gewählten Zeitraum und aktualisiert die UI.
  Future<void> deleteLogsBetween(DateTime fromDate, DateTime toDate) async {
    await _repository.deletePainLogsBetween(fromDate, toDate);
    await loadLogs(); // Lädt die Daten neu und ruft notifyListeners() auf
  }

  //TODO[API]: Test Schmerzgraph zu simulieren und Fake Daten dafür anzulegen
  /// Befüllt Isar mit Demo-Schmerzdaten und aktualisiert den Provider
  Future<void> seedDemoData() async {
    //await _repository.seedDemoPainLogs();
    await _repository.seedDemoPainLogs2();
    await loadLogs(); // Lädt alle Logs neu und benachrichtigt die Widgets (notifyListeners)
  }
}