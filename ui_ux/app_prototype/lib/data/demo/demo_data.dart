import 'package:app_prototype/data/enum/gender.dart';
import 'package:app_prototype/data/enum/contraindication.dart';
import 'package:app_prototype/data/enum/skill_level.dart';

import '../models/models.dart';
import '../../core/theme/app_colors.dart';

/// Statische Demo-Daten für die UI.
///
/// Übernommen aus dem JSX-Prototyp (V11). Dienen ausschließlich dazu, die
/// Oberfläche mit realistischen Inhalten zu zeigen und durchklickbar zu machen.
/// Das spätere Laden echter Daten übernimmt die API-/Backend-Gruppe; diese
/// Klasse wird dann einfach ersetzt.
class DemoData {
  DemoData._();

  static User profile = User(
    name: 'Lena Müller',
    gender: Gender.female,
    age: 20,
    weight: 60,
    height: 170,
    contraindication: [Contraindication.kneeIssue.label],
    skillLevel: SkillLevel.intermediate,
    email: 'lena.mueller@email.de',
    goal: 'Beweglichkeit verbessern',
    region: 'Knie',
    regions: ['Knie', 'Schulter'],
    mobility: 'Mittel',
    reminder: '08:00',
  );

  static final List<Exercise> exercises = [
    const Exercise(
      id: 'ex1',
      name: 'Sanfte Schulterlockerung',
      region: 'Schulter',
      duration: '4 Min',
      durationSec: '04:12',
      difficulty: 'Leicht',
      description:
          'Eine sanfte Mobilisationsübung für den Schultergürtel. Hilft, Verspannungen zu lösen und die Beweglichkeit zu verbessern.',
      steps: [
        'Setz dich aufrecht hin, Schultern entspannt.',
        'Rolle beide Schultern langsam 8-mal nach hinten.',
        'Wechsle die Richtung und rolle 8-mal nach vorne.',
        'Atme ruhig und gleichmäßig weiter.',
        'Wiederhole das Ganze für eine zweite Runde.',
      ],
      safety: [
        'Bewege dich nur im schmerzfreien Bereich.',
        'Bei stechenden Schmerzen sofort stoppen.',
        'Halte den Nacken locker, nicht in die Schultern ziehen.',
      ],
      done: true,
    ),
    const Exercise(
      id: 'ex2',
      name: 'Kniemobilisation im Sitzen',
      region: 'Knie',
      duration: '5 Min',
      durationSec: '05:30',
      difficulty: 'Leicht',
      description:
          'Eine schonende Übung zur Verbesserung der Kniebeweglichkeit ohne Belastung.',
      steps: [
        'Setz dich aufrecht auf einen Stuhl.',
        'Strecke ein Bein langsam aus, halte 3 Sekunden.',
        'Senke das Bein wieder ab, ohne den Boden zu berühren.',
        '10 Wiederholungen pro Seite.',
        'Eine kurze Pause, dann zweite Runde.',
      ],
      safety: [
        'Keine schnellen Bewegungen.',
        'Im schmerzfreien Bereich bleiben.',
      ],
      done: false,
    ),
  ];

  static final List<Exercise> library = [
    const Exercise(
      id: 'lib1',
      name: 'Kniebeuge an der Wand',
      region: 'Knie',
      duration: '5 Min',
      difficulty: 'Mittel',
      description: 'Schonende Kraftübung mit Rückenkontakt zur Wand.',
      steps: [
        'Stell dich mit dem Rücken an eine glatte Wand, Füße schulterbreit.',
        'Rutsche langsam die Wand hinunter, bis die Knie ca. 90° gebeugt sind.',
        'Halte die Position 5 Sekunden, Rücken bleibt an der Wand.',
        'Schiebe dich wieder hoch und strecke die Beine durch.',
      ],
      safety: [
        'Knie nicht über die Zehenspitzen hinaus schieben.',
        'Rücken flach an der Wand halten.',
      ],
    ),
    const Exercise(
      id: 'lib2',
      name: 'Schulterkreisen',
      region: 'Schulter',
      duration: '3 Min',
      difficulty: 'Leicht',
      description: 'Lockert den Schultergürtel und verbessert die Mobilität.',
      steps: [
        'Aufrecht hinstellen, Arme locker an den Seiten.',
        'Beide Schultern langsam nach vorne, oben, hinten, unten kreisen – 8 Mal.',
        'Richtung wechseln: 8 Mal rückwärts.',
      ],
      safety: ['Schultern nicht hochziehen.', 'Langsam und kontrolliert bewegen.'],
    ),
    const Exercise(
      id: 'lib5',
      name: 'Beinheben im Liegen',
      region: 'Knie',
      duration: '6 Min',
      difficulty: 'Mittel',
      description: 'Kräftigt die vordere Oberschenkelmuskulatur.',
      steps: [
        'Auf den Rücken legen, ein Bein anwinkeln.',
        'Das gestreckte Bein langsam 20 cm anheben.',
        '5 Sekunden halten, langsam senken.',
      ],
      safety: ['Rücken bleibt flach am Boden.'],
    ),
    const Exercise(
      id: 'lib6',
      name: 'Rückenstrecker',
      region: 'Rücken',
      duration: '5 Min',
      difficulty: 'Leicht',
      description: 'Stärkt die untere Rückenmuskulatur.',
      steps: ['In Bauchlage Arme und Beine leicht anheben.', '5 Sekunden halten.'],
      safety: ['Nicht überstrecken.'],
    ),
    const Exercise(
      id: 'lib7',
      name: 'Wadendehnung',
      region: 'Knie',
      duration: '4 Min',
      difficulty: 'Leicht',
      description: 'Dehnt Waden und entlastet das Knie.',
      steps: ['Ausfallschritt, hinteres Bein gestreckt.', '20 Sekunden halten.'],
      safety: ['Ferse am Boden lassen.'],
    ),
    const Exercise(
      id: 'lib8',
      name: 'Armkreisen',
      region: 'Schulter',
      duration: '3 Min',
      difficulty: 'Leicht',
      description: 'Mobilisiert das Schultergelenk.',
      steps: ['Arme seitlich ausstrecken.', 'Kleine Kreise, dann größer werden.'],
      safety: ['Im schmerzfreien Bereich bleiben.'],
    ),
    const Exercise(
      id: 'lib10',
      name: 'Katze-Kuh',
      region: 'Rücken',
      duration: '5 Min',
      difficulty: 'Leicht',
      description: 'Mobilisiert die gesamte Wirbelsäule.',
      steps: ['Im Vierfüßlerstand Rücken rund machen.', 'Dann sanft durchhängen lassen.'],
      safety: ['Ruhig atmen, nicht ruckartig bewegen.'],
    ),
    const Exercise(
      id: 'lib11',
      name: 'Nackendehnung',
      region: 'Nacken',
      duration: '4 Min',
      difficulty: 'Leicht',
      description: 'Löst Verspannungen im Nacken.',
      steps: ['Kopf langsam zur Seite neigen.', '10 Sekunden halten, Seite wechseln.'],
      safety: ['Keine Kreisbewegungen.'],
    ),
    const Exercise(
      id: 'lib12',
      name: 'Beckenkippen',
      region: 'Rücken',
      duration: '5 Min',
      difficulty: 'Leicht',
      description: 'Mobilisiert die Lendenwirbelsäule.',
      steps: ['In Rückenlage Becken sanft kippen.', 'Bauch anspannen, wieder lösen.'],
      safety: ['Kleine Bewegungen genügen.'],
    ),
  ];

  static final List<TrainingPlan> plans = [
    const TrainingPlan(
      id: 'plan-knie',
      name: 'Knie-Plan',
      region: 'Knie',
      goal: 'Stabilität & Mobilität',
      exerciseIds: ['lib1', 'lib5', 'lib7'],
      sessionsPerWeek: 3,
      completedSessions: 4,
      source: 'empfohlen',
      color: PlanColors.tuerkis,
    ),
    const TrainingPlan(
      id: 'plan-schulter',
      name: 'Schulter-Plan',
      region: 'Schulter',
      goal: 'Beweglichkeit & Entlastung',
      exerciseIds: ['lib2', 'lib8', 'lib11'],
      sessionsPerWeek: 2,
      completedSessions: 2,
      source: 'empfohlen',
      color: PlanColors.gold,
    ),
    const TrainingPlan(
      id: 'plan-ruecken',
      name: 'Rücken-Plan',
      region: 'Rücken',
      goal: 'Haltung & Kräftigung',
      exerciseIds: ['lib6', 'lib10', 'lib12'],
      sessionsPerWeek: 3,
      completedSessions: 1,
      source: 'eigen',
      color: PlanColors.marine,
    ),
  ];

  static final List<TrainingPlan> suggestedPlans = [
    const TrainingPlan(
      id: 'suggest-buero',
      name: 'Büro-Plan',
      region: 'Büro',
      goal: 'Haltung im Sitzen',
      description: 'Gegen verspannten Nacken und müden Rücken am Schreibtisch.',
      exerciseIds: ['lib3', 'lib11', 'lib10', 'lib2'],
    ),
    const TrainingPlan(
      id: 'suggest-morgen',
      name: 'Morgen-Routine',
      region: 'Morgen',
      goal: 'Sanft in den Tag starten',
      description: 'Weckt Körper und Geist mit leichter Mobilität.',
      exerciseIds: ['lib12', 'lib4', 'lib11'],
    ),
    const TrainingPlan(
      id: 'suggest-abend',
      name: 'Abend-Entspannung',
      region: 'Abend',
      goal: 'Loslassen vor dem Schlaf',
      description: 'Ruhige Übungen, die helfen abzuschalten.',
      exerciseIds: ['lib10', 'lib4', 'lib12'],
    ),
  ];

  static final List<Appointment> appointments = [
    const Appointment(
      id: 'ap1',
      day: '22',
      month: 'Mai',
      weekday: 'Donnerstag',
      time: '14:30',
      practice: 'Physio Praxis Müller',
      room: 'Raum 2',
      therapist: 'Frau Wagner',
      address: 'Hauptstraße 14, 21255 Tostedt',
      type: 'Krankengymnastik',
    ),
    const Appointment(
      id: 'ap3',
      day: '05',
      month: 'Jun',
      weekday: 'Donnerstag',
      time: '15:00',
      practice: 'Physio Praxis Müller',
      room: 'Raum 1',
      therapist: 'Frau Wagner',
      address: 'Hauptstraße 14, 21255 Tostedt',
      type: 'Manuelle Therapie',
    ),
  ];

  static List<PainLog> painLogs() => [
        PainLog(
          level: 4,
          region: 'Knie',
          note: 'Morgens etwas steif, besser nach Übung.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          dateKey: '2026-06-10',
        ),
        PainLog(
          level: 3,
          region: 'Knie',
          note: '',
          date: DateTime.now().subtract(const Duration(days: 2)),
          dateKey: '2026-06-09',
        ),
        PainLog(
          level: 8,
          region: 'Knie',
          note: 'Starke Schmerzen im rechten Knie während der Übung.',
          date: DateTime.parse('2026-06-03'),
          dateKey: '2026-06-03',
        ),
      ];

  /// Schmerzverlauf je Region — relativ zum heutigen Datum (für Charts).
  static Map<String, List<PainLog>> painHistory() {
    PainLog rel(int offset, int level, String region, [String? note]) {
      final d = DateTime.now().add(Duration(days: offset));
      return PainLog(
        level: level,
        region: region,
        note: note ?? '',
        date: d,
        dateKey: PainLog.keyOf(d),
      );
    }

    return {
      'Knie': [
        rel(-32, 10, 'Knie', 'Schlimmster Tag'),
        rel(-28, 9, 'Knie'),
        rel(-24, 8, 'Knie'),
        rel(-20, 7, 'Knie'),
        rel(-16, 5, 'Knie'),
        rel(-12, 4, 'Knie'),
        rel(-8, 3, 'Knie', 'Spürbar besser'),
        rel(-4, 2, 'Knie'),
        rel(-1, 2, 'Knie', 'Nur leicht morgens'),
      ],
      'Schulter': [
        rel(-30, 8, 'Schulter'),
        rel(-22, 6, 'Schulter'),
        rel(-15, 4, 'Schulter'),
        rel(-9, 3, 'Schulter'),
        rel(-3, 2, 'Schulter'),
      ],
      'Rücken': [
        rel(-31, 9, 'Rücken', 'Kreuzschmerzen'),
        rel(-24, 6, 'Rücken'),
        rel(-14, 5, 'Rücken'),
        rel(-6, 3, 'Rücken', 'Spürbar besser'),
        rel(-2, 3, 'Rücken'),
      ],
    };
  }

  static List<CalendarEvent> calendarEvents() => [
        const CalendarEvent(
            id: 'j-10a', title: 'Knie Routine', region: 'Knie', dateKey: '2026-06-10', done: true),
        const CalendarEvent(
            id: 'j-11a', title: 'Knie Routine', region: 'Knie', dateKey: '2026-06-11'),
        const CalendarEvent(
            id: 'j-11b',
            title: 'Schulter Mobilität',
            region: 'Schulter',
            dateKey: '2026-06-11',
            done: true),
        const CalendarEvent(
            id: 'j-11c', title: 'Rücken Kräftigung', region: 'Rücken', dateKey: '2026-06-11'),
        const CalendarEvent(
            id: 'ap2',
            title: 'Kontrolltermin',
            region: '',
            dateKey: '2026-06-05',
            time: '15:00',
            type: 'appointment',
            note: 'Frau Wagner'),
      ];

  // ── Person 1: Begrüßungstexte (wechselnd) ───────────────────
  static const List<String> welcomeMessages = [
    'Wusstest du, dass schon wenige Minuten Bewegung täglich deinem Körper helfen, neue Muster zu lernen?',
    'Jede Einheit zählt – auch die kleinen Schritte bringen dich voran.',
    'Schön, dass du dir heute wieder Zeit für dich nimmst.',
    'Regelmäßigkeit schlägt Intensität. Bleib einfach dran – das reicht völlig.',
    'Dein Körper erinnert sich an jede Bewegung. Heute ist ein guter Tag dafür.',
    'Kleine Routinen, große Wirkung – Schritt für Schritt zu mehr Beweglichkeit.',
    'Atme durch und beweg dich sanft. Du tust gerade etwas Gutes für dich.',
    'Konstanz ist dein stärkster Verbündeter. Lass uns weitermachen.',
  ];

  /// Wählt eine Begrüßung passend zum Wochentag (stabil über den Tag).
  static String welcomeOfToday() {
    final dayIndex = DateTime.now().day; // 1..31
    return welcomeMessages[dayIndex % welcomeMessages.length];
  }

  // ── Person 1: Alltagstipps je Körperregion ──────────────────
  static const Map<String, RegionTip> tipsByRegion = {
    'Knie': RegionTip(
      title: 'Grüner Regenerations-Smoothie',
      teaser: 'Nährstoffe, die dein Knie von innen unterstützen.',
      body:
          'Mixe Spinat, Banane, Ingwer und Kurkuma mit Mandelmilch. Entzündungshemmende '
          'Wirkstoffe helfen dem Kniegelenk bei der Erholung.',
      duration: '1 Min lesen',
    ),
    'Rücken': RegionTip(
      title: 'Grüner Regenerations-Smoothie',
      teaser: 'Nährstoffe, die deinen Rücken von innen unterstützen.',
      body:
          'Mixe Spinat, Banane, Ingwer und Kurkuma mit Mandelmilch. Entzündungshemmende '
          'Wirkstoffe helfen der Rückenmuskulatur bei der Erholung.',
      duration: '1 Min lesen',
    ),
    'Schulter': RegionTip(
      title: 'Grüner Regenerations-Smoothie',
      teaser: 'Nährstoffe, die deine Schulter von innen unterstützen.',
      body:
          'Mixe Spinat, Banane, Ingwer und Kurkuma mit Mandelmilch. Entzündungshemmende '
          'Wirkstoffe helfen der Schultermuskulatur bei der Erholung.',
      duration: '1 Min lesen',
    ),
    'Hüfte': RegionTip(
      title: 'Grüner Regenerations-Smoothie',
      teaser: 'Nährstoffe, die deine Hüfte von innen unterstützen.',
      body:
          'Mixe Spinat, Banane, Ingwer und Kurkuma mit Mandelmilch. Entzündungshemmende '
          'Wirkstoffe helfen dem Hüftgelenk bei der Erholung.',
      duration: '1 Min lesen',
    ),
    'Nacken': RegionTip(
      title: 'Grüner Regenerations-Smoothie',
      teaser: 'Nährstoffe, die deinen Nacken von innen unterstützen.',
      body:
          'Mixe Spinat, Banane, Ingwer und Kurkuma mit Mandelmilch. Entzündungshemmende '
          'Wirkstoffe helfen der Nackenmuskulatur bei der Erholung.',
      duration: '1 Min lesen',
    ),
  };

  /// Tipp passend zur Hauptregion des Profils (Fallback: Knie).
  static RegionTip tipForRegion(String region) =>
      tipsByRegion[region] ?? tipsByRegion['Knie']!;
}
