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

  //TODO[API]: Test Schmerzgraph zu simulieren und Fake Daten dafür anzulegen
  /// Generiert abwechslungsreiche Demo-Schmerzeinträge für verschiedene Zeiträume
  /*
  Future<void> seedDemoPainLogs() async {
    final now = DateTime.now();
    final List<PainLog> fakeLogs = [];

    // Helper zum Hinzufügen eines Eintrags
    void addLog(BodyPart region, DateTime date, int level, String note) {
      fakeLogs.add(PainLog(
        level: level,
        region: region,
        note: note,
        date: date,
        dateKey: PainLog.keyOf(date),
      ));
    }

    // 1. RÜCKEN (back): 2 Jahre (24 Monate), alle ~3 Tage ein Eintrag
    for (int month = 0; month < 24; month++) {
      for (int dayOffset = 0; dayOffset < 28; dayOffset += 3) {
        final date = DateTime(now.year, now.month - month, 28 - dayOffset);
        if (date.isAfter(now)) continue;

        // Erzeugt eine leichte Wellenbewegung von Schmerzlevel 3 bis 8
        final level = ((month + dayOffset) % 6) + 3;
        final note = level > 6 ? 'Morgens steif' : (level < 4 ? 'Wenig Beschwerden' : '');
        addLog(BodyPart.back, date, level, note);
      }
    }

    // 2. KNIE (knees) & BEINE (legs): 6 Monate, alle ~2 Tage
    for (int month = 0; month < 6; month++) {
      for (int dayOffset = 0; dayOffset < 28; dayOffset += 2) {
        final date = DateTime(now.year, now.month - month, 28 - dayOffset);
        if (date.isAfter(now)) continue;

        // Knie wird über Zeit besser (sinkender Trend)
        final kneeLevel = (month + 2).clamp(1, 9);
        addLog(BodyPart.knees, date, kneeLevel, kneeLevel > 6 ? 'Nach Treppensteigen' : '');

        // Beine schwanken
        final legLevel = ((dayOffset % 5) + 2).clamp(1, 10);
        addLog(BodyPart.legs, date, legLevel, '');
      }
    }

    // 3. NACKEN (neck): Nur für den aktuellen Monat, fast täglich
    for (int day = 1; day <= now.day; day += 1) {
      final date = DateTime(now.year, now.month, day);
      final level = (8 - (day % 4)).clamp(1, 10); // Leicht abnehmend
      addLog(BodyPart.neck, date, level, day % 5 == 0 ? 'Bildschirmarbeit' : '');
    }

    // 4. SPRUNGGELENKE (ankles): Nur die letzten 5 Tage
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      final level = 7 - i; // Nimmt von 7 auf 3 ab
      addLog(BodyPart.ankles, date, level, i == 0 ? 'Heute umgeknickt' : 'Wird besser');
    }

    // In Isar schreiben (Verwendet saveOrUpdate um Duplikate am selben Tag zu vermeiden)
    for (final log in fakeLogs) {
      await saveOrUpdatePainLog(log);
    }
  }
  */

  /// Generiert realistische, organische Schmerzeinträge für Testzwecke.
  Future<void> seedDemoPainLogs2() async {
    final now = DateTime.now();
    final List<PainLog> fakeLogs = [];

    void addLog(BodyPart region, DateTime date, int level, String note) {
      fakeLogs.add(PainLog(
        level: level,
        region: region,
        note: note,
        date: date,
        dateKey: PainLog.keyOf(date),
      ));
    }

    // ───────────────────────────────────────────────────────────────────────────
    // 1. RÜCKEN (back): 2 Jahre – Chronisch mit Akutphasen & beschwerdefreien Monaten
    // ───────────────────────────────────────────────────────────────────────────
    // Vordefiniertes Monats-Muster für 24 Monate (Index 0 = aktueller Monat, 23 = vor 2 Jahren)
    // Werte stellen ein typisches Basis-Niveau des jeweiligen Monats dar.
    final backMonthlyBase = [
      3, 2, 6, 7, 4, 2, 1, 1, 2, 5, 8, 6, // Jahr 1 (Monate 0 bis 11)
      3, 2, 2, 4, 7, 5, 3, 2, 1, 3, 6, 4, // Jahr 2 (Monate 12 bis 23)
    ];

    for (int monthIndex = 0; monthIndex < 24; monthIndex++) {
      final baseLevel = backMonthlyBase[monthIndex];

      // Nicht an jedem Tag wird eingetragen (realistisches Nutzerverhalten)
      final daysToLog = [2, 5, 9, 14, 18, 22, 26];

      for (final day in daysToLog) {
        final date = DateTime(now.year, now.month - monthIndex, day);
        if (date.isAfter(now)) continue;

        // Kleine organische Abweichung (-1, 0, +1)
        final dailyVariation = (day % 3) - 1;
        final level = (baseLevel + dailyVariation).clamp(1, 10);

        String note = '';
        if (level >= 8) note = 'Starke Steifheit am Morgen';
        else if (level >= 6) note = 'Langes Sitten im Büro';
        else if (level <= 2 && day == 14) note = 'Schmerzfrei nach Spaziergang';

        addLog(BodyPart.back, date, level, note);
      }
    }

    // ───────────────────────────────────────────────────────────────────────────
    // 2. KNIE (knees): 6 Monate – Vorzeigbarer Besserungsverlauf (Reha/Training)
    // ───────────────────────────────────────────────────────────────────────────
    // Von hoch (Monat 5 vor 6 Monaten) zu niedrig (aktueller Monat)
    final kneeProgressiveLevels = [
      [2, 1, 2, 1, 2, 1], // Monat 0 (Aktuell - fast schmerzfrei)
      [3, 2, 3, 2, 4, 2], // Monat -1
      [4, 4, 3, 5, 4, 3], // Monat -2
      [6, 5, 5, 6, 5, 4], // Monat -3
      [7, 6, 8, 7, 6, 6], // Monat -4
      [8, 9, 7, 8, 8, 7], // Monat -5 (Vor 6 Monaten - Reha-Start)
    ];

    for (int monthIndex = 0; monthIndex < 6; monthIndex++) {
      final monthValues = kneeProgressiveLevels[monthIndex];
      final days = [3, 7, 12, 17, 22, 27];

      for (int i = 0; i < days.length; i++) {
        final date = DateTime(now.year, now.month - monthIndex, days[i]);
        if (date.isAfter(now)) continue;

        final level = monthValues[i];
        final note = (level >= 7) ? 'Knie instabil beim Treppensteigen' : '';

        addLog(BodyPart.knees, date, level, note);
      }
    }

    // ───────────────────────────────────────────────────────────────────────────
    // 3. BEINE (legs): 6 Monate – Schwankend je nach Sport/Aktivität
    // ───────────────────────────────────────────────────────────────────────────
    for (int monthIndex = 0; monthIndex < 6; monthIndex++) {
      // Unregelmäßige Abstände
      final days = [1, 4, 8, 11, 15, 19, 23, 28];

      for (int i = 0; i < days.length; i++) {
        final date = DateTime(now.year, now.month - monthIndex, days[i]);
        if (date.isAfter(now)) continue;

        // Wechselt zwischen leichten Beschwerden und Muskelkater/Überlastung
        final level = (i % 2 == 0) ? ((monthIndex + i) % 3) + 2 : ((i * 3) % 5) + 4;
        final note = level > 6 ? 'Intensives Beintraining' : '';

        addLog(BodyPart.legs, date, level, note);
      }
    }

    // ───────────────────────────────────────────────────────────────────────────
    // 4. NACKEN (neck): 1 Monat – Typisches Büro-Muster (Wochenende gut, Fr. hoch)
    // ───────────────────────────────────────────────────────────────────────────
    for (int day = 1; day <= now.day; day++) {
      final date = DateTime(now.year, now.month, day);
      int level;
      String note = '';

      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        level = 1 + (day % 2); // Wochenende: 1 - 2
        if (day % 6 == 0) note = 'Entspannter Sonntag';
      } else if (date.weekday == DateTime.friday) {
        level = 7 + (day % 2); // Freitag: 7 - 8 (Arbeitswoche spürbar)
        note = 'Langer Tag am Laptop';
      } else {
        level = 3 + (day % 3); // unter der Woche: 3 - 5
      }

      addLog(BodyPart.neck, date, level, note);
    }

    // ───────────────────────────────────────────────────────────────────────────
    // 5. SPRUNGGELENKE (ankles): 5 Tage – Akut-Verletzung mit täglicher Besserung
    // ───────────────────────────────────────────────────────────────────────────
    final ankleAcutePattern = [
      (daysAgo: 4, level: 9, note: 'Umgeknickt beim Laufen'),
      (daysAgo: 3, level: 7, note: 'Gekühlt und hochgelegt'),
      (daysAgo: 2, level: 5, note: 'Schwellung geht zurück'),
      (daysAgo: 1, level: 4, note: 'Leichtes Auftreten möglich'),
      (daysAgo: 0, level: 2, note: 'Fast schmerzfrei im Alltag'),
    ];

    for (final entry in ankleAcutePattern) {
      final date = now.subtract(Duration(days: entry.daysAgo));
      addLog(BodyPart.ankles, date, entry.level, entry.note);
    }

    // In Isar speichern
    for (final log in fakeLogs) {
      await saveOrUpdatePainLog(log);
    }
  }
}