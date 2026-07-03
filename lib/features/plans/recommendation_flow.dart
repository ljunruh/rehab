import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../data/demo/plan_options.dart';

/// PERSON 2 — Geführter Empfehlungs-Flow.
///
/// Fragt Region und Ziel ab und schlägt daraufhin einen passenden Plan
/// (aus vorhandenen Übungen) vor, den man direkt übernehmen kann.
/// Entspricht RecommendationFlow im JSX-Prototyp (ohne API).
class RecommendationFlow extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSaved;

  const RecommendationFlow({
    super.key,
    required this.onBack,
    required this.onSaved,
  });

  @override
  State<RecommendationFlow> createState() => _RecommendationFlowState();
}

class _RecommendationFlowState extends State<RecommendationFlow> {
  int _step = 1; // 1: Region, 2: Ziel, 3: Vorschlag
  String? _region;
  String? _goal;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 110),
      children: [
        AppBackButton(
          onTap: _step == 1 ? widget.onBack : () => setState(() => _step--),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('EMPFEHLUNG · SCHRITT $_step VON 3', style: AppText.micro),
        const SizedBox(height: AppSpacing.md),

        if (_step == 1) ...[
          Text('Welche Region möchtest du trainieren?',
              style: AppText.screenTitle),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final r in PlanOptions.regions)
                AppChip(
                  label: r,
                  active: _region == r,
                  onTap: () => setState(() {
                    _region = r;
                    _step = 2;
                  }),
                ),
            ],
          ),
        ],

        if (_step == 2) ...[
          Text('Was ist dein Ziel?', style: AppText.screenTitle),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final g in PlanOptions.goals)
                AppChip(
                  label: g,
                  active: _goal == g,
                  onTap: () => setState(() {
                    _goal = g;
                    _step = 3;
                  }),
                ),
            ],
          ),
        ],

        if (_step == 3) _buildSuggestion(app),
      ],
    );
  }

  Widget _buildSuggestion(UiState app) {
    final region = _region ?? 'Knie';
    final goal = _goal ?? 'Mobilität';

    // Passende Übungen aus der Bibliothek (nach Region, sonst erste 3).
    final matching =
        app.library.where((e) => e.region == region).take(3).toList();
    final exercises = matching.isNotEmpty ? matching : app.library.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dein empfohlener Plan', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text('Basierend auf $region · $goal', style: AppText.caption),
        const SizedBox(height: AppSpacing.lg),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: PlanColors.tuerkis,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: Text('$region-Plan', style: AppText.cardTitle)),
                  AppTag(region, variant: TagVariant.region),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final ex in exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 18, color: AppColors.sage),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(ex.name, style: AppText.body)),
                      Text(ex.duration, style: AppText.caption),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        PrimaryButton(
          label: 'Diesen Plan übernehmen',
          icon: Icons.check,
          onPressed: () {
            final plan = TrainingPlan(
              id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
              name: '$region-Plan',
              region: region,
              goal: goal,
              exerciseIds: exercises.map((e) => e.id).toList(),
              sessionsPerWeek: 3,
              source: 'empfohlen',
              color: PlanColors.tuerkis,
            );
            app.savePlan(plan);
            widget.onSaved();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Andere Auswahl treffen',
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }
}
