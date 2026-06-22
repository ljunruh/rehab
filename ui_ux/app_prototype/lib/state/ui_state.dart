import 'package:flutter/foundation.dart';
import '../core/theme/app_colors.dart';
import '../data/models/models.dart';
import '../data/demo/demo_data.dart';

/// Zentraler UI-Zustand der App (Provider / ChangeNotifier).
///
/// Hält alle Daten, die die Screens anzeigen, und die Aktionen, die die
/// Oberfläche auslösen kann (Übung abhaken, Plan archivieren, Schmerz
/// eintragen …). Die Daten kommen aus [DemoData] und liegen direkt im
/// Speicher — passend für ein UI/UX-Projekt ohne Backend.
///
/// Sobald die API-Gruppe ihre Datenquelle hat, ersetzt sie hier lediglich
/// die Initialisierung in [load] (bzw. füllt die Felder aus ihrer Quelle).
/// Die Screens und ihre Logik bleiben unverändert.
///
/// Aufteilung nach den vier UI-Bereichen, damit das Team parallel arbeiten
/// kann:
///   • Person 1 (Home):      profile, exercises, streak, completedSessions
///   • Person 2 (Pläne):     plans, suggestedPlans, library
///   • Person 3 (Fortschr.): painLogs, painHistory, calendarEvents
///   • Person 4 (Profil):    profile-Updates, appointments, Navigation
class UiState extends ChangeNotifier {
  UiState() {
    load();
  }

  // ── Daten (direkt aus den Demo-Daten) ───────────────────────
  late UserProfile profile;
  late List<Exercise> exercises;
  late List<Exercise> library;
  late List<TrainingPlan> plans;
  late List<TrainingPlan> suggestedPlans;
  late List<Appointment> appointments;
  late List<CalendarEvent> calendarEvents;
  late List<PainLog> painLogs;
  late Map<String, List<PainLog>> painHistory;

  int streak = 12;
  int completedSessionsThisWeek = 2;

  /// Lädt die Demo-Daten in den Zustand.
  void load() {
    profile = DemoData.profile;
    exercises = List.of(DemoData.exercises);
    library = List.of(DemoData.library);
    plans = List.of(DemoData.plans);
    suggestedPlans = List.of(DemoData.suggestedPlans);
    appointments = List.of(DemoData.appointments);
    calendarEvents = DemoData.calendarEvents();
    painLogs = DemoData.painLogs();
    painHistory = DemoData.painHistory();
  }

  // ── Toast (einfacher transienter Hinweis) ───────────────────
  String? _toast;
  String? get toast => _toast;

  void showToast(String message) {
    _toast = message;
    notifyListeners();
  }

  void clearToast() {
    _toast = null;
    notifyListeners();
  }

  // ── Übungen (Person 1) ──────────────────────────────────────
  Exercise? exerciseById(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  void completeExercise(String id) {
    exercises = [
      for (final e in exercises) e.id == id ? e.copyWith(done: true) : e
    ];
    showToast('Gut gemacht — Übung abgeschlossen.');
  }

  /// Wochen-Fortschritt je aktivem Plan (für die Ringe auf dem Home-Screen).
  /// Liefert pro Plan: Farbe, erledigte Einheiten und Wochenziel.
  List<WeeklyRing> get weeklyRings {
    return [
      for (final p in activePlans)
        WeeklyRing(
          label: p.region.isNotEmpty ? p.region : p.name,
          color: p.color ?? AppColors.sage,
          done: p.completedSessions.clamp(0, p.sessionsPerWeek),
          goal: p.sessionsPerWeek,
        ),
    ];
  }

  /// Aktive Körperregionen (Profil-Hauptregion + Regionen aller aktiven Pläne).
  List<String> get activeRegions {
    final set = <String>{profile.region};
    for (final p in activePlans) {
      if (p.region.isNotEmpty) set.add(p.region);
    }
    return set.toList();
  }

  /// Starter-Info für eine Region: Anzahl/erledigte Übungen + Gesamtminuten.
  /// Wird im "Womit fängst du heute an?"-Karussell genutzt.
  ({int total, int done, int minutes, String goal}) starterFor(String region) {
    final regExercises = exercises.where((e) => e.region == region).toList();
    int minutes = 0;
    for (final e in regExercises) {
      minutes += int.tryParse(e.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    final done = regExercises.where((e) => e.done).length;
    // Ziel-Text aus dem passenden Plan (für die Rubrik-Ableitung).
    String goal = '';
    for (final p in activePlans) {
      if (p.region == region) {
        goal = p.goal;
        break;
      }
    }
    return (total: regExercises.length, done: done, minutes: minutes, goal: goal);
  }

  // ── Pläne (Person 2) ────────────────────────────────────────
  /// Aktive (nicht archivierte) Pläne.
  List<TrainingPlan> get activePlans =>
      plans.where((p) => !p.archived).toList();

  TrainingPlan? planById(String id) {
    for (final p in plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  void savePlan(TrainingPlan plan) {
    // Pro Region genau ein aktiver Plan: bestehenden ersetzen/zusammenführen.
    final existing =
        plans.indexWhere((p) => p.region == plan.region && !p.archived);
    if (existing >= 0 && plans[existing].id != plan.id) {
      final merged = plans[existing].copyWith(
        name: plan.name,
        goal: plan.goal,
        exerciseIds: {
          ...plans[existing].exerciseIds,
          ...plan.exerciseIds,
        }.toList(),
      );
      plans[existing] = merged;
      showToast('Plan aktualisiert.');
    } else {
      final idx = plans.indexWhere((p) => p.id == plan.id);
      if (idx >= 0) {
        plans[idx] = plan;
      } else {
        plans = [...plans, plan];
      }
      showToast('Plan gespeichert.');
    }
    notifyListeners();
  }

  void deletePlan(String id) {
    plans = plans.where((p) => p.id != id).toList();
    showToast('Plan gelöscht.');
  }

  void archivePlan(String id) {
    plans = [
      for (final p in plans) p.id == id ? p.copyWith(archived: true) : p
    ];
    showToast('Plan archiviert.');
  }

  void restorePlan(String id) {
    plans = [
      for (final p in plans) p.id == id ? p.copyWith(archived: false) : p
    ];
    showToast('Plan wiederhergestellt.');
  }

  void finishTraining(String planId) {
    plans = [
      for (final p in plans)
        p.id == planId
            ? p.copyWith(completedSessions: p.completedSessions + 1)
            : p
    ];
    completedSessionsThisWeek += 1;
    streak += 1;
    showToast('Training abgeschlossen.');
  }

  void addCustomExercise(Exercise ex) {
    library = [...library, ex];
    showToast('Eigene Übung gespeichert.');
  }

  /// Fügt Übungen zu einem bestehenden Plan hinzu (ohne Duplikate).
  void addExercisesToPlan(String planId, List<String> exerciseIds) {
    plans = [
      for (final p in plans)
        if (p.id == planId)
          p.copyWith(
            exerciseIds: {...p.exerciseIds, ...exerciseIds}.toList(),
          )
        else
          p,
    ];
    showToast('Übungen hinzugefügt.');
  }

  // ── Fortschritt / Kalender (Person 3) ───────────────────────
  void addPainLog(PainLog log) {
    painLogs = [log, ...painLogs];
    showToast('Eintrag gespeichert.');
  }

  void addCalendarEvent(CalendarEvent event) {
    calendarEvents = [...calendarEvents, event];
    showToast('Termin gespeichert.');
  }

  // ── Profil (Person 4) ───────────────────────────────────────
  void updateProfile(UserProfile newProfile) {
    profile = newProfile;
    showToast('Profil aktualisiert.');
  }
}
