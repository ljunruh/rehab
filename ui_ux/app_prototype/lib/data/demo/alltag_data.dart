import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/alltag_guide.dart';

/// Demo-Inhalte für "Schonung im Alltag".
///
/// WICHTIG: Im JSX-Prototyp (V12) gibt es zwei Konstanten,
/// SCHONUNG_SITUATION (5 Regionen) und SCHONUNG_GUIDES (12 generische
/// Leitfäden) — aber SCHONUNG_GUIDES wird NIRGENDS gerendert (toter
/// Code im Prototyp selbst). Nur SCHONUNG_SITUATION erscheint
/// tatsächlich in der App (als "Meine Schonung im Alltag" und im
/// rotierenden "Beschwerdebezogen"-Slider auf dem Pläne-Screen).
/// Deshalb bildet diese Datei nur die 5 Regionen ab.
class AlltagData {
  /// Schonungs-Situationskarten, je Körperregion — alle 5 Regionen.
  static const List<AlltagGuide> schonung = [
    AlltagGuide(
      id: 'sit-knie',
      region: 'Knie',
      title: 'Knie im Alltag schonen',
      tag: 'Knie',
      subtitle: 'Sitzen · Treppe · Laufen · Schlafen',
      icon: Icons.gps_fixed,
      bg: AppColors.sage,
      fg: AppColors.white,
      sections: [
        GuideSection(
          title: 'Sitzen',
          icon: Icons.watch_later_outlined,
          intro:
              'Langes Sitzen in einer Position steift das Knie ein – kleine Pausen machen viel aus.',
          items: [
            'Alle 30 Min. Bein kurz strecken und beugen',
            'Knie nicht dauerhaft überkreuzen',
            'Sitzhöhe wählen, dass Knie ca. 90° gebeugt sind',
            'Bei Schwellungen Bein hochlagern',
          ],
        ),
        GuideSection(
          title: 'Treppe steigen',
          icon: Icons.bolt,
          intro:
              'Mit der richtigen Technik lässt sich der Druck auf das Kniegelenk deutlich reduzieren.',
          items: [
            'Hochgehen: stärkeres Bein zuerst',
            'Runtergehen: schwächeres Bein zuerst',
            'Geländer zur Entlastung nutzen',
            'Bei Schmerz lieber den Aufzug nutzen',
          ],
        ),
        GuideSection(
          title: 'Laufen & Gehen',
          icon: Icons.map_outlined,
          intro:
              'Gleichmäßige, weiche Schritte schonen das Gelenk besser als abrupte Bewegungen.',
          items: [
            'Dämpfendes Schuhwerk tragen',
            'Kürzere, häufigere Schritte statt großer Schritte',
            'Bergab besonders langsam und kontrolliert',
            'Pausen einbauen, bevor Schmerz entsteht',
          ],
        ),
        GuideSection(
          title: 'Schlafen',
          icon: Icons.dark_mode_outlined,
          intro:
              'Die Schlafposition beeinflusst, wie gut das Knie über Nacht regenerieren kann.',
          items: [
            'Kleines Kissen unter die Kniekehle bei Rückenlage',
            'Seitlage: Kissen zwischen die Knie legen',
            'Bein leicht erhöht lagern bei Schwellung',
            'Wärmflasche vor dem Schlafen entspannt die Muskulatur',
          ],
        ),
      ],
    ),
    AlltagGuide(
      id: 'sit-schulter',
      region: 'Schulter',
      title: 'Schulter im Alltag schonen',
      tag: 'Schulter',
      subtitle: 'Tragen · Arbeiten · Schlafen · Greifen',
      icon: Icons.gps_fixed,
      bg: AppColors.sage,
      fg: AppColors.white,
      sections: [
        GuideSection(
          title: 'Tragen & Heben',
          icon: Icons.work_outline,
          intro:
              'Einseitige Belastung ist eine der häufigsten Ursachen für Schulterprobleme.',
          items: [
            'Rucksack statt Umhängetasche bevorzugen',
            'Last nah am Körper halten',
            'Regelmäßig die Seite wechseln',
            'Schweres nie mit ausgestrecktem Arm heben',
          ],
        ),
        GuideSection(
          title: 'Am Arbeitsplatz',
          icon: Icons.work_outline,
          intro:
              'Fehlhaltungen am Schreibtisch belasten die Schulter oft unbemerkt über Stunden.',
          items: [
            'Ellenbogen etwa auf Tischhöhe',
            'Bildschirm auf Augenhöhe, nicht seitlich',
            'Schultern bewusst locker lassen, nicht hochziehen',
            'Alle 45 Min. kurz aufstehen und bewegen',
          ],
        ),
        GuideSection(
          title: 'Greifen & Überkopf',
          icon: Icons.gps_fixed,
          intro:
              'Überkopfbewegungen sind die größte Belastung für eine gereizte Schulter.',
          items: [
            'Gegenstände nicht mit ausgestrecktem Arm greifen',
            'Hohe Regale: Tritt benutzen statt Recken',
            'Im schmerzfreien Bereich bleiben',
            'Schwere Gegenstände nah am Körper führen',
          ],
        ),
        GuideSection(
          title: 'Schlafen',
          icon: Icons.dark_mode_outlined,
          intro:
              'Die falsche Schlafposition kann Schulterschmerzen verstärken oder auslösen.',
          items: [
            'Rückenlage mit flachem Kissen ist am schonendsten',
            'Seitenlage nur auf der gesunden Seite',
            'Kleines Kissen zwischen Arm und Körper',
            'Bauchlage meiden – verdreht die Schulter',
          ],
        ),
      ],
    ),
    AlltagGuide(
      id: 'sit-ruecken',
      region: 'Rücken',
      title: 'Rücken im Alltag schonen',
      tag: 'Rücken',
      subtitle: 'Sitzen · Heben · Auto · Schlafen',
      icon: Icons.gps_fixed,
      bg: AppColors.sage,
      fg: AppColors.white,
      sections: [
        GuideSection(
          title: 'Sitzen',
          icon: Icons.watch_later_outlined,
          intro:
              'Die häufigste Belastung für den Rücken ist langes, statisches Sitzen.',
          items: [
            'Becken aufrecht, Lendenstütze nutzen',
            'Füße flach am Boden, Knie ca. 90°',
            'Alle 45–60 Min. kurz aufstehen',
            'Höhenverstellbarer Schreibtisch wenn möglich',
          ],
        ),
        GuideSection(
          title: 'Heben & Bücken',
          icon: Icons.fitness_center,
          intro:
              'Richtiges Heben schützt die Bandscheiben – auch bei leichten Gegenständen.',
          items: [
            'In die Knie gehen, Rücken gerade halten',
            'Last nah am Körper führen',
            'Mit den Beinen hochdrücken, nicht mit dem Rücken',
            'Beim Tragen nicht seitlich verdrehen',
          ],
        ),
        GuideSection(
          title: 'Auto fahren',
          icon: Icons.map_outlined,
          intro:
              'Langes Sitzen im Auto belastet die Wirbelsäule – die Sitzposition macht den Unterschied.',
          items: [
            'Lehne leicht nach hinten geneigt (ca. 100–110°)',
            'Lendenstütze aktivieren oder Kissen nutzen',
            'Knie etwa auf Hüfthöhe',
            'Alle 1–2 Stunden kurze Pause einlegen',
          ],
        ),
        GuideSection(
          title: 'Schlafen',
          icon: Icons.dark_mode_outlined,
          intro:
              'Eine rückenfreundliche Schlafposition unterstützt die Regeneration der Wirbelsäule.',
          items: [
            'Seitenlage mit Kissen zwischen den Knien',
            'Rückenlage: kleines Kissen unter die Knie',
            'Bauchschläfer: Kissen unter den Bauch legen',
            'Matratze sollte Wirbelsäule stützen, nicht durchhängen',
          ],
        ),
      ],
    ),
    AlltagGuide(
      id: 'sit-nacken',
      region: 'Nacken',
      title: 'Nacken im Alltag schonen',
      tag: 'Nacken',
      subtitle: 'Bildschirm · Handy · Schlafen · Fahren',
      icon: Icons.gps_fixed,
      bg: AppColors.sage,
      fg: AppColors.white,
      sections: [
        GuideSection(
          title: 'Am Bildschirm',
          icon: Icons.work_outline,
          intro:
              'Ein zu tief stehender Monitor zwingt den Kopf nach vorne – die häufigste Ursache für Nackenverspannungen.',
          items: [
            'Obere Bildschirmkante auf Augenhöhe',
            'Abstand ca. eine Armlänge',
            'Bildschirm leicht nach hinten neigen',
            'Alle 30 Min. in die Ferne schauen',
          ],
        ),
        GuideSection(
          title: 'Handy & Tablet',
          icon: Icons.medical_services_outlined,
          intro:
              'Der gesenkte Blick aufs Handy belastet den Nacken enorm – schon kleine Korrekturen helfen.',
          items: [
            'Smartphone Richtung Augenhöhe heben',
            'Kopf aufrecht halten, nicht nach vorne schieben',
            'Längeres Tippen lieber mit Auflage',
            'Zwischendurch Nacken sanft kreisen lassen',
          ],
        ),
        GuideSection(
          title: 'Auto fahren',
          icon: Icons.map_outlined,
          intro:
              'Die Kopfstütze ist kein Komfort-Feature – richtig eingestellt schützt sie die Halswirbelsäule.',
          items: [
            'Kopfstütze auf Hinterkopfhöhe einstellen',
            'Kein Abstand zwischen Kopf und Stütze',
            'Spiegel so einstellen, dass kein Verdrehen nötig ist',
            'Bei langer Fahrt: Nackenstütze nutzen',
          ],
        ),
        GuideSection(
          title: 'Schlafen',
          icon: Icons.dark_mode_outlined,
          intro:
              'Das Kissen entscheidet, ob der Nacken über Nacht entspannt oder verspannt aufwacht.',
          items: [
            'Kissen sollte Kopf und Hals stützen, nicht hochdrücken',
            'Seitenlage: Kissen in Schulterbreite',
            'Rückenlage: flaches, leicht konturiertes Kissen',
            'Bauchlage meiden – verdreht den Nacken stark',
          ],
        ),
      ],
    ),
    AlltagGuide(
      id: 'sit-huefte',
      region: 'Hüfte',
      title: 'Hüfte im Alltag schonen',
      tag: 'Hüfte',
      subtitle: 'Sitzen · Aufstehen · Laufen · Schlafen',
      icon: Icons.gps_fixed,
      bg: AppColors.sage,
      fg: AppColors.white,
      sections: [
        GuideSection(
          title: 'Sitzen',
          icon: Icons.watch_later_outlined,
          intro:
              'Langes Sitzen verkürzt die Hüftbeuger – ein häufiger Auslöser für Hüft- und Rückenschmerzen.',
          items: [
            'Hüfte nicht unter 90° beugen beim Sitzen',
            'Sitzkeil oder Kehlkissen kann helfen',
            'Regelmäßig aufstehen und die Hüfte strecken',
            'Überkreuzen der Beine vermeiden',
          ],
        ),
        GuideSection(
          title: 'Aufstehen & Hinsetzen',
          icon: Icons.bolt,
          intro:
              'Die meiste Belastung entsteht beim Übergang – kontrollierte Bewegungen schonen das Gelenk.',
          items: [
            'Hände auf den Oberschenkeln abstützen',
            'Körpergewicht gleichmäßig auf beide Beine verteilen',
            'Langsam und kontrolliert aufstehen',
            'Stuhlhöhe anpassen – nicht zu tief sitzen',
          ],
        ),
        GuideSection(
          title: 'Laufen & Gehen',
          icon: Icons.map_outlined,
          intro:
              'Die Hüfte stabilisiert jeden Schritt – gutes Schuhwerk und Körperhaltung machen den Unterschied.',
          items: [
            'Dämpfendes Schuhwerk mit gutem Halt',
            'Aufrechte Haltung, Blick nach vorne',
            'Gleichmäßiges Tempo, keine abrupten Starts',
            'Bergab: kleinere Schritte, Körper leicht nach hinten',
          ],
        ),
        GuideSection(
          title: 'Schlafen',
          icon: Icons.dark_mode_outlined,
          intro:
              'Die Hüfte braucht nachts eine Entlastungsposition – sonst beginnt der Tag schon mit Steifheit.',
          items: [
            'Seitenlage: Kissen zwischen die Knie legen',
            'Rückenlage: Kissen unter die Knie',
            'Auf der betroffenen Seite wenn möglich nicht liegen',
            'Hüfte beim Aufwachen langsam mobilisieren',
          ],
        ),
      ],
    ),
  ];
}
