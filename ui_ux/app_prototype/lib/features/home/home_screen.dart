import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/demo/demo_data.dart';
import '../../state/ui_state.dart';
import 'concentric_rings.dart';
import 'home_hero.dart';
import 'pain_carousel.dart';
import 'starter_carousel.dart';
import 'tip_of_day_card.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 1 — HOME & TIPPS                                  │
/// │  Dunkler Hero-Kopf, Starter-Karussell, Schmerz-Karussell,│
/// │  Wochen-Ringe, Tipp-für-heute (mit Schloss).             │
/// │  Aufbau exakt nach Prototyp-Screenshots.                 │
/// └──────────────────────────────────────────────────────────┘
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;

  /// Startet das Training für eine Region (aus dem Starter-Karussell).
  final ValueChanged<Plan> onStartTraining;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    required this.onStartTraining,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user!; // Ist zu dem Zeitpunkt schon vorhanden
    final rings = app.weeklyRings;
    final tip = DemoData.tipForRegion(user.region);

    return Container(
      color: AppColors.sageMid,
      child: Stack(
        children: [
          // ── Fester grüner Hero-Hintergrund (scrollt NICHT mit) ──
          HomeHero(
            firstName: user.name.split(' ').first,
            initials: user.initials,
            welcome: DemoData.welcomeOfToday(),
            onAvatarTap: onOpenProfile,
            showAvatar: false,
          ),

          // ── Scrollbarer Inhalt: creme Sheet gleitet über den Hero ──
          SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Transparenter Platzhalter, gibt den Hero darunter frei.
                // Höhe = ungefähre Hero-Höhe minus Überlappung (28).
                SizedBox(height: 196 + MediaQuery.of(context).padding.top),

                // Cremefarbenes Sheet
                Container(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: SectionTitle('Womit fängst du heute an?',
                          style: AppText.screenTitle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                    //TODO[API]
                    StarterCarousel(onStartTraining: onStartTraining),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Schmerz-Karussell
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: SectionTitle('Wie geht es dir heute?',
                          style: AppText.screenTitle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                    const PainCarousel(),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Wochenziel-Streifen (konzentrische Ringe pro Bereich)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        child: rings.isEmpty
                            ? _EmptyRings()
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ConcentricRings(
                                    rings: rings,
                                    size: 66,
                                    strokeWidth: 7,
                                    gap: 3,
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (final r in rings)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 9,
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                    color: r.color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    r.label,
                                                    style: AppText.caption
                                                        .copyWith(
                                                      fontSize: 12.5,
                                                      color: AppColors.text,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${r.done}/${r.goal}',
                                                  style: AppText.caption
                                                      .copyWith(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: r.done >= r.goal
                                                        ? AppColors.sageDeep
                                                        : AppColors
                                                            .textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Divider(
                                              color: AppColors.beige,
                                              height: 1),
                                        ),
                                        const SizedBox(height: 6),
                                        Builder(builder: (context) {
                                          final weeks = (app.streak / 7)
                                              .floor()
                                              .clamp(1, 999);
                                          final weekWord =
                                              weeks == 1 ? 'Woche' : 'Wochen';
                                          return RichText(
                                            text: TextSpan(
                                              style: AppText.caption.copyWith(
                                                  color: AppColors
                                                      .textSecondary),
                                              children: [
                                                TextSpan(
                                                  text: '$weeks ',
                                                  style: AppText.caption
                                                      .copyWith(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color:
                                                        AppColors.sageDeep,
                                                  ),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '$weekWord bist du schon dabei!'),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
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
                            duration: tip.duration,
                            body: tip.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),

          // ── Tappbarer Avatar oben rechts (immer klickbar) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 24,
            child: HeaderAvatar(
              initials: user.initials,
              onTap: onOpenProfile,
            ),
          ),
        ],
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
