import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
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
  final ValueChanged<Plan> onStartTraining;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    required this.onStartTraining,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final planProvider = context.watch<PlanProvider>();
    final planLogExerciseProvider = context.watch<PlanLogExerciseProvider>();

    final user = userProvider.user!;

    // Ausgelagerte Daten aus dem Provider
    final rings = planProvider.weeklyRings;
    final weeks = planLogExerciseProvider.weeklyStreak;
    final tip = DemoData.tipForRegion(user.region);

    return Container(
      color: AppColors.sageMid,
      child: Stack(
        children: [
          // ── Fester grüner Hero-Hintergrund ──
          HomeHero(
            firstName: user.name.split(' ').first,
            initials: user.initials,
            welcome: DemoData.welcomeOfToday(),
            onAvatarTap: onOpenProfile,
            showAvatar: false,
          ),

          // ── Scrollbarer Inhalt ──
          SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        child: SectionTitle(
                          'Womit fängst du heute an?',
                          style: AppText.screenTitle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      StarterCarousel(onStartTraining: onStartTraining),
                      const SizedBox(height: AppSpacing.sectionGap),

                      // Schmerz-Karussell
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenH),
                        child: SectionTitle(
                          'Wie geht es dir heute?',
                          style: AppText.screenTitle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const PainCarousel(),
                      const SizedBox(height: AppSpacing.sectionGap),

                      // Wochenziel-Streifen
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenH),
                        child: Consumer<PlanProvider>(
                          builder: (context, provider, child) {
                            final currentRings = provider.weeklyRings;

                            return AppCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              child: currentRings.isEmpty
                                  ? const _EmptyRings()
                                  : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ConcentricRings(rings: currentRings, size: 66),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (final r in currentRings)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5),
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
                                                    style: AppText.caption.copyWith(
                                                      fontSize: 12.5,
                                                      color: AppColors.text,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  '${r.done}/${r.goal}',
                                                  style: AppText.caption.copyWith(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: r.done >= r.goal
                                                        ? AppColors.sageDeep
                                                        : AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 4),
                                          child: Divider(color: AppColors.beige, height: 1),
                                        ),
                                        const SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            style: AppText.caption.copyWith(
                                                color: AppColors.textSecondary),
                                            children: [
                                              TextSpan(
                                                text: '$weeks ',
                                                style: AppText.caption.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.sageDeep,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${weeks == 1 ? 'Woche' : 'Wochen'} bist du schon dabei!',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

          // ── Avatar oben rechts ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 24,
            child: HeaderAvatar(
              initials: user.initials,
              onTap: onOpenProfile,
            ),
          ),
    //TODO[API]: Test um WeeklyStreak zu simulieren und Fake Daten dafür anzulegen
          /*
    ElevatedButton(
    onPressed: () => context.read<PlanLogExerciseProvider>().seedTestData(4, activePlans: context.read<PlanProvider>().activePlans),
    child: const Text('4 Wochen Streak simulieren'),
    )    */
        ],
      ),
    );
  }
}

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
