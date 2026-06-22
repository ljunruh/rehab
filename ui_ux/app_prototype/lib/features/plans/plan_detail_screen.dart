import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// PERSON 2 — Detailansicht eines Trainingsplans.
///
/// Zeigt Plan-Kopf (Name, Region-Tag, Ziel, Farbe), Fortschritt, die Liste
/// der enthaltenen Übungen und Aktionen (Training starten, archivieren,
/// löschen). Entspricht PlanDetail im JSX-Prototyp.
class PlanDetailScreen extends StatelessWidget {
  final String planId;
  final VoidCallback onBack;
  final ValueChanged<String> onStartTraining;
  final ValueChanged<String> onAddExercise;

  const PlanDetailScreen({
    super.key,
    required this.planId,
    required this.onBack,
    required this.onStartTraining,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final plan = app.planById(planId);

    if (plan == null) {
      return Center(child: Text('Plan nicht gefunden.', style: AppText.body));
    }

    // Übungen des Plans aus der Bibliothek auflösen.
    final exercises = <Exercise>[];
    for (final id in plan.exerciseIds) {
      for (final e in app.library) {
        if (e.id == id) {
          exercises.add(e);
          break;
        }
      }
    }

    final totalMinutes = exercises.fold<int>(0, (sum, e) {
      final m = int.tryParse(e.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + m;
    });

    final accent = plan.color ?? AppColors.sage;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        110,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBackButton(onTap: onBack),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: AppColors.text),
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              onSelected: (value) {
                if (value == 'archive') {
                  app.archivePlan(plan.id);
                  onBack();
                } else if (value == 'delete') {
                  app.deletePlan(plan.id);
                  onBack();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Text('Archivieren', style: AppText.body),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Löschen',
                      style: AppText.body.copyWith(color: PlanColors.koralle)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),

        // Kopfbereich mit Plan-Farbe
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppTag(plan.region, variant: TagVariant.region),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(plan.name, style: AppText.screenTitle),
              const SizedBox(height: 4),
              Text(plan.goal, style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Kennzahlen
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                value: '${exercises.length}',
                label: 'Übungen',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                value: '$totalMinutes',
                label: 'Minuten',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                value: '${plan.completedSessions}',
                label: 'Einheiten',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        const SectionTitle('Übungen im Plan'),
        ...exercises.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _PlanExerciseRow(
                  index: entry.key + 1,
                  exercise: entry.value,
                  accent: accent,
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.lg),

        PrimaryButton(
          label: 'Training starten',
          icon: Icons.play_arrow,
          onPressed:
              exercises.isEmpty ? null : () => onStartTraining(plan.id),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Übung hinzufügen',
          icon: Icons.add,
          onPressed: () => onAddExercise(plan.id),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(label: 'Zurück', onPressed: onBack),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      background: AppColors.offwhite,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.base,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Text(value,
              style: AppText.cardTitle.copyWith(
                fontSize: 20,
                color: AppColors.sage,
              )),
          const SizedBox(height: 2),
          Text(label, style: AppText.micro, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PlanExerciseRow extends StatelessWidget {
  final int index;
  final Exercise exercise;
  final Color accent;

  const _PlanExerciseRow({
    required this.index,
    required this.exercise,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.iconSmall),
            ),
            child: Text('$index',
                style: AppText.cardTitle.copyWith(color: AppColors.sageDeep)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: AppText.cardTitle),
                Text('${exercise.duration} · ${exercise.difficulty}',
                    style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
