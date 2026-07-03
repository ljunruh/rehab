import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/demo/plan_options.dart';

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
  String _filterRegion = 'Alle';
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final plan = app.planById(widget.planId);
    if (plan == null) {
      return Center(child: Text('Plan nicht gefunden.', style: AppText.body));
    }
    final alreadyIn = plan.exerciseIds.toSet();

    var list = app.library;
    if (_filterRegion != 'Alle') {
      list = list.where((e) => e.region == _filterRegion).toList();
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 24),
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

              // Region-Filter
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final r in PlanOptions.regionFilter)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: AppChip(
                          label: r,
                          active: _filterRegion == r,
                          onTap: () => setState(() => _filterRegion = r),
                        ),
                      ),
                  ],
                ),
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
                                ? const Icon(Icons.check,
                                    size: 16, color: AppColors.white)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.name, style: AppText.cardTitle),
                                Text(
                                    '${ex.region} · ${ex.duration}${inPlan ? ' · bereits im Plan' : ''}',
                                    style: AppText.caption),
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
              AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, 24),
          color: AppColors.cream,
          child: PrimaryButton(
            label: _selected.isEmpty
                ? 'Übungen auswählen'
                : '${_selected.length} Übung${_selected.length == 1 ? '' : 'en'} hinzufügen',
            icon: Icons.add,
            disabled: _selected.isEmpty,
            onPressed: _selected.isEmpty
                ? null
                : () {
                    app.addExercisesToPlan(
                        widget.planId, _selected.toList());
                    widget.onAdded();
                  },
          ),
        ),
      ],
    );
  }
}
