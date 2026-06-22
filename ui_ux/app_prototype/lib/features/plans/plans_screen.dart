import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../navigation/screen_header.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 2 — PLÄNE & TRAINING                              │
/// │  Verantwortlich für: PlansScreen, PlanDetail, PlanCreate,│
/// │  PlanTraining, Empfehlungs-/Bibliotheks-Flows.           │
/// │  Aktionen über UiState.savePlan / deletePlan / …   │
/// └──────────────────────────────────────────────────────────┘
class PlansScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;
  final ValueChanged<String> onOpenPlan;
  final VoidCallback onOpenLibrary;

  const PlansScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenPlan,
    required this.onOpenLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
      children: [
        ScreenHeader(
          greeting: 'Deine Pläne',
          subtitle: '${app.activePlans.length} aktive Trainingspläne',
          initials: profile.initials,
          onAvatarTap: onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...app.activePlans.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                  child: Dismissible(
                    key: ValueKey(p.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.alertSoft,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.archive_outlined,
                              size: 18, color: AppColors.text),
                          SizedBox(width: 6),
                          Text('Archivieren'),
                        ],
                      ),
                    ),
                    onDismissed: (_) => app.archivePlan(p.id),
                    child: _PlanCard(plan: p, onTap: () => onOpenPlan(p.id)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'Alle Übungen ansehen',
                icon: Icons.fitness_center,
                onPressed: onOpenLibrary,
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle('Empfehlungen für dich'),
              ...app.suggestedPlans.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                  child: _SuggestedCard(
                    plan: p,
                    onAdd: () => app.savePlan(
                      p.copyWith(source: 'empfohlen'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback onTap;
  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = plan.sessionsPerWeek == 0
        ? 0.0
        : (plan.completedSessions / (plan.sessionsPerWeek * 4)).clamp(0.0, 1.0);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: plan.color ?? AppColors.sage,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(plan.name, style: AppText.cardTitle)),
              AppTag(plan.region, variant: TagVariant.region),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(plan.goal, style: AppText.caption),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.beige,
              valueColor: AlwaysStoppedAnimation(plan.color ?? AppColors.sage),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${plan.completedSessions} Einheiten absolviert',
              style: AppText.micro),
        ],
      ),
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback onAdd;
  const _SuggestedCard({required this.plan, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      background: AppColors.offwhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.name, style: AppText.cardTitle),
          const SizedBox(height: 4),
          if (plan.description != null)
            Text(plan.description!, style: AppText.caption),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Plan hinzufügen',
            icon: Icons.add,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
