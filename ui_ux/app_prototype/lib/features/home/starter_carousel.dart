import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/region_icons.dart';
import '../../state/ui_state.dart';

/// "Womit fängst du heute an?" — wischbares Karussell mit Trainings-Startern
/// je Region. Jede Karte: Ziel-Eyebrow, Region, Übungszahl/Minuten,
/// Status-Fortschritt und ein "<Region>-Training starten"-Button.
/// Entspricht dem Today-Regions-Slider im JSX-Prototyp.
class StarterCarousel extends StatefulWidget {
  final ValueChanged<Plan> onStartTraining;
  const StarterCarousel({super.key, required this.onStartTraining});

  @override
  State<StarterCarousel> createState() => _StarterCarouselState();
}

class _StarterCarouselState extends State<StarterCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final planLogExerciseProvider = context.watch<PlanLogExerciseProvider>();
    final plans = planProvider.activePlans;

    if (plans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controller,
            itemCount: plans.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final plan = plans[i];
              final isActive = i == _index;
              final goals = plan.effectiveGoals;

              // -----------------------------------------------------------------
              // NEU: Präzise Fortschritts- & Statusberechnung
              // -----------------------------------------------------------------
              final isLimitReached = plan.completedSessions >= plan.sessionsPerWeek;
              final progress = planLogExerciseProvider.getTodayProgress(plan);

              final int done = progress.done;
              final int total = progress.total;
              final int durationMinutes = plan.duration;

              final bool isFullyDone = isLimitReached || (total > 0 && done == total);

              final String statusText;
              if (isLimitReached) {
                statusText = 'Wochenziel erreicht';
              } else if (total == 0) {
                statusText = 'Heute nichts geplant';
              } else if (done == total) {
                statusText = 'Alles erledigt';
              } else if (done > 0) {
                statusText = '$done von $total erledigt';
              } else {
                statusText = 'Noch offen';
              }
              final double pct = isLimitReached ? 1.0 : (total > 0 ? done / total : 0.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  background: isActive ? AppColors.white : AppColors.offwhite,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _RegionBadge(region: plan.region),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (goals.isNotEmpty) ...[
                                  Text(goals.first.label.toUpperCase(),
                                      style: AppText.micro),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  plan.name.isNotEmpty ? plan.name : plan.region.label,
                                  // Lange Plannamen (z. B. "Schultern-Plan(empfohlen)")
                                  // brachen bisher um und sprengten die feste
                                  // Kartenhöhe -> "BOTTOM OVERFLOWED BY 15 PIXELS".
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.cardTitle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  total == 0
                                      ? 'Keine Übungen'
                                      : '$total ${total == 1 ? 'Übung' : 'Übungen'} · ca. $durationMinutes Min.',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('STATUS', style: AppText.micro),
                          Text(
                            statusText,
                            style: AppText.label.copyWith(
                              color: isFullyDone ? AppColors.sageDeep : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: AppColors.beige,
                          valueColor: AlwaysStoppedAnimation(
                            isFullyDone ? AppColors.sageDeep : AppColors.sageMid,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      PrimaryButton(
                        label: isFullyDone
                            ? 'Heute erledigt'
                            : done > 0
                            ? 'Weiter trainieren'
                            : '${plan.region.label}-Training starten',
                        icon: isFullyDone ? Icons.check : Icons.arrow_forward,
                        disabled: isFullyDone || total == 0,
                        onPressed: (isFullyDone || total == 0)
                            ? null
                            : () => widget.onStartTraining(plan),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (plans.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          _Dots(count: plans.length, active: _index),
        ],
      ],
    );
  }
}

/// Rendert das geforderte SvgPicture.asset für alle BodyParts
class _RegionBadge extends StatelessWidget {
  final BodyPart region;
  const _RegionBadge({required this.region});

  @override
  Widget build(BuildContext context) {
    final icon = RegionIcons.of(region.name) ?? 'assets/icons/regions/back.svg';
    return SvgPicture.asset(icon, width: 52, height: 52);
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.standard,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == active ? AppColors.sageMid : AppColors.beige,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
