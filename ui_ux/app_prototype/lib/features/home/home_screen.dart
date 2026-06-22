import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/demo/demo_data.dart';
import 'home_hero.dart';
import 'starter_carousel.dart';
import 'pain_carousel.dart';
import 'concentric_rings.dart';
import 'tip_of_day_card.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 1 — HOME & TIPPS                                  │
/// │  Dunkler Hero-Kopf, Starter-Karussell, Schmerz-Karussell,│
/// │  Wochen-Ringe, Tipp-für-heute (mit Schloss).             │
/// │  Aufbau exakt nach Prototyp-Screenshots.                 │
/// └──────────────────────────────────────────────────────────┘
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenTip;

  /// Startet das Training für eine Region (aus dem Starter-Karussell).
  final ValueChanged<String> onStartRegion;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenTip,
    required this.onStartRegion,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;
    final rings = app.weeklyRings;

    // Tipp ist freigeschaltet, wenn diese Woche mindestens eine Einheit
    // abgeschlossen wurde (Demo-Logik).
    final tipUnlocked = app.completedSessionsThisWeek > 0;
    final tip = DemoData.tipForRegion(profile.region);

    return Container(
      color: AppColors.cream,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Dunkelgrüner Hero-Kopf ──
            HomeHero(
              firstName: profile.name.split(' ').first,
              initials: profile.initials,
              welcome: DemoData.welcomeOfToday(),
              onAvatarTap: onOpenProfile,
            ),

            // ── Cremefarbenes Sheet, gleitet über den Hero ──
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(0, 22, 0, 102),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Starter-Karussell
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: SectionTitle('Womit fängst du heute an?'),
                    ),
                    StarterCarousel(onStartRegion: onStartRegion),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Schmerz-Karussell
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: SectionTitle('Wie geht es dir heute?'),
                    ),
                    const PainCarousel(),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Wochen-Ringe
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: rings.isEmpty
                            ? _EmptyRings()
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Diese Woche',
                                          style: AppText.sectionHeader),
                                      Text('${app.streak} Tage Streak',
                                          style: AppText.caption.copyWith(
                                              color: AppColors.sage)),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.base),
                                  Row(
                                    children: [
                                      ConcentricRings(
                                          rings: rings, size: 150),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                          child: RingsLegend(rings: rings)),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Tipp für heute
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Tipp für heute'),
                          TipOfDayCard(
                            title: tip.title,
                            body: tip.teaser,
                            locked: !tipUnlocked,
                            onTap: tipUnlocked ? onOpenTip : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hinweis, wenn (noch) keine aktiven Pläne für Ringe vorhanden sind.
class _EmptyRings extends StatelessWidget {
  const _EmptyRings();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      alignment: Alignment.center,
      child: Text(
        'Noch keine aktiven Pläne.\nLege einen Plan an, um deinen Wochenfortschritt zu sehen.',
        style: AppText.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
