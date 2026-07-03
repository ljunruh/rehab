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
class PlanDetailScreen extends StatefulWidget {
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
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final plan = app.planById(widget.planId);

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
        // Kopf: Zurück + Stift/Haken
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBackButton(onTap: widget.onBack),
            GestureDetector(
              onTap: () => setState(() => _editing = !_editing),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _editing ? AppColors.sageLight : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(_editing ? Icons.check : Icons.edit_outlined,
                    size: 18, color: AppColors.sageDeep),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),

        // Cover-Bild (Plan-Farbe als Fläche)
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Center(
            child: Icon(Icons.fitness_center,
                size: 44, color: accent.withOpacity(0.5)),
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Titel
        Text(plan.name, style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),

        // Tags
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppTag(plan.region, variant: TagVariant.region),
            AppTag(plan.goal, variant: TagVariant.goal),
            if (plan.source == 'empfohlen')
              AppTag('Empfohlen', variant: TagVariant.source),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text('Kalenderfarbe',
                  style: AppText.label.copyWith(color: AppColors.white)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),

        // Kennzahlen
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(value: '${exercises.length}', label: 'ÜBUNGEN'),
              _MiniStat(value: '$totalMinutes Min', label: 'GESAMTDAUER'),
              _MiniStat(
                  value: '${plan.completedSessions}×', label: 'ABGESCHLOSSEN'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Farbauswahl (nur im Bearbeiten-Modus)
        if (_editing) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KALENDERFARBE', style: AppText.micro),
                const SizedBox(height: AppSpacing.base),
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    for (final c in PlanColors.all)
                      GestureDetector(
                        onTap: () {
                          app.updatePlanColor(plan.id, c);
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: accent.value == c.value
                                ? Border.all(
                                    color: AppColors.text, width: 3)
                                : null,
                          ),
                          child: accent.value == c.value
                              ? const Icon(Icons.check,
                                  size: 22, color: AppColors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],

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
              exercises.isEmpty ? null : () => widget.onStartTraining(plan.id),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Übung hinzufügen',
          icon: Icons.add,
          onPressed: () => widget.onAddExercise(plan.id),
        ),
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
    return Column(
      children: [
        Text(label, style: AppText.micro, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(value,
            style: AppText.screenTitle.copyWith(fontSize: 20)),
      ],
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
