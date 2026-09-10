import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/demo/plan_options.dart';
import '../../data/enum/body_part.dart';
import '../../data/enum/goal.dart';
import '../../data/models/api/exercise.dart';
import '../../data/provider/exercise_provider.dart';
import '../../data/provider/plan_provider.dart';
import '../../data/repository/exercise_repository.dart';

/// PERSON 2 — Übungen zu einem bestehenden Plan hinzufügen.
///
/// Zeigt die Bibliothek mit Mehrfachauswahl (Häkchen); bereits im Plan
/// enthaltene Übungen sind ausgegraut und nicht erneut wählbar.
/// Entspricht AddExerciseScreen im JSX-Prototyp.
class AddExerciseScreen extends StatefulWidget {
  final String planId;
  final VoidCallback onBack;
  final VoidCallback onAdded;

  const AddExerciseScreen({
    super.key,
    required this.planId,
    required this.onBack,
    required this.onAdded,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final Set<String> _selected = {};
  List<Exercise> _library = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final planProvider = context.read<PlanProvider>();
    final plan = planProvider.plans.firstWhere(
      (p) => p.id == widget.planId,
      orElse: () => planProvider.plan!,
    );

    // Leere Zielliste = keine Einschränkung, greift nur bei Plänen ohne Zielauswahl.
    final exercises = await context
        .read<ExerciseProvider>()
        .repo
        .getFilterdExcercises(plan.region, plan.allGoals);

    if (exercises != null && mounted) {
      setState(() {
        _library = exercises;
      });
    }
  }

  // das habe ich implementiert , da die filtermethode wegen deutsch und englisch
  //nicht funktioniert hat
  BodyPart _findBodyPart(String text) {
    final clean = text.trim().toLowerCase();
    for (final bp in BodyPart.values) {
      if (bp == BodyPart.none) continue;
      if (bp.name.toLowerCase() == clean ||
          bp.label.toLowerCase().contains(clean) ||
          clean.contains(bp.label.toLowerCase()) ||
          bp.labelEN.toLowerCase().contains(clean) ||
          clean.contains(bp.labelEN.toLowerCase())) {
        return bp;
      }
    }
    return BodyPart.none;
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final plan = planProvider.plans.firstWhere(
      (p) => p.id == widget.planId,
      orElse: () => planProvider.plan!,
    );
    final alreadyIn = plan.exercises.map((e) => e.id).toSet();

    final exerciseRepo = context.read<ExerciseProvider>().repo;
    var list = _library;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.base,
              AppSpacing.screenH,
              24,
            ),
            children: [
              AppBackButton(onTap: widget.onBack),
              const SizedBox(height: AppSpacing.lg),
              Text('Übungen hinzufügen', style: AppText.screenTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${_selected.length} ausgewählt · Plan: ${plan.name}',
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpacing.base),

              ...list.map((ex) {
                final inPlan = alreadyIn.contains(ex.id);
                final selected = _selected.contains(ex.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Opacity(
                    opacity: inPlan ? 0.45 : 1,
                    child: AppCard(
                      onTap: inPlan
                          ? null
                          : () => setState(() {
                              if (selected) {
                                _selected.remove(ex.id);
                              } else {
                                _selected.add(ex.id);
                              }
                            }),
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.sage
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: selected
                                    ? AppColors.sage
                                    : AppColors.beige,
                                width: 1.5,
                              ),
                            ),
                            child: (selected || inPlan)
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.label, style: AppText.cardTitle),
                                Text(
                                  '${ex.bodyParts.map((bodyPart) => BodyPartExt.fromString(bodyPart).label).join(', ')} · ${ex.duration} Min${inPlan ? ' · bereits im Plan' : ''}',
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            24,
          ),
          color: AppColors.cream,
          child: PrimaryButton(
            label: _selected.isEmpty
                ? 'Übungen auswählen'
                : '${_selected.length} Übung${_selected.length == 1 ? '' : 'en'} hinzufügen',
            icon: Icons.add,
            disabled: _selected.isEmpty,
            onPressed: _selected.isEmpty
                ? null
                : () async {
                    final selectedExercises = _library
                        .where((e) => _selected.contains(e.id))
                        .toList();
                    await planProvider.addExercisesToPlan(
                      widget.planId,
                      selectedExercises,
                    );
                    widget.onAdded();
                  },
          ),
        ),
      ],
    );
  }
}
