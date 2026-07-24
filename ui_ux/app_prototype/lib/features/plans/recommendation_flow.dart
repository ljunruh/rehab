import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/api/api_models.dart';
import '../../data/provider/exercise_provider.dart';
import '../../data/provider/plan_provider.dart';
import '../../data/enum/body_part.dart';
import '../../data/enum/goal.dart';

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
  BodyPart? _region;
  Goal? _goal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        110,
      ),
      children: [
        AppBackButton(
          onTap: _step == 1 ? widget.onBack : () => setState(() => _step--),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('EMPFEHLUNG · SCHRITT $_step VON 3', style: AppText.micro),
        const SizedBox(height: AppSpacing.md),

        if (_step == 1) ...[
          Text(
            'Welche Region möchtest du trainieren?',
            style: AppText.screenTitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final r in BodyPart.values.where((e) => e != BodyPart.none))
                AppChip(
                  label: r.label,
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
              for (final g in Goal.values.where((e) => e != Goal.none))
                AppChip(
                  label: g.label,
                  active: _goal == g,
                  onTap: () async {
                    setState(() {
                      _goal = g;
                      _step = 3;
                    });
                    // Übungen  über den ExerciseProvider laden (aus API/FUSEKI, und wird  lokal zwischengespeichert)(API Gruppe)
                    final exerciseProvider = context.read<ExerciseProvider>();
                    await exerciseProvider.loadAll(bodyPart: _region!, goal: g);

                    // Empfehlungsplan im PlanProvider generieren lassen (Random-Filterung)
                    final planProvider = context.read<PlanProvider>();
                    planProvider.generateRecommandedPlan(
                      exerciseProvider.exercises,
                      _region!,
                      g,
                    );
                  },
                ),
            ],
          ),
        ],

        if (_step == 3) _buildSuggestion(context),
      ],
    );
  }

  ///bearbeitet von der API Gruppe , echte daten werden verwendet .
  Widget _buildSuggestion(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final plan = planProvider.recommendedPlan;

    // 2. Zeige eine Ladeanzeige, solange die API noch arbeitet und der Plan null ist
    if (plan == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.sage)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dein empfohlener Plan', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          // 1. Hier nutzen wir plan.region und plan.goal direkt
          'Basierend auf ${plan.region.label} · ${plan.goal.label}',
          style: AppText.caption,
        ),
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
                    child: Text(
                      // 2. Hier nutzen wir plan.region
                      '${plan.region.label}-Plan',
                      style: AppText.cardTitle,
                    ),
                  ),
                  // 2. Hier ebenfalls plan.region
                  AppTag(plan.region.label, variant: TagVariant.region),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // 3. Hier schleifen wir durch plan.exercises
              for (final ex in plan.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.sage,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // 4. Hier nutzen wir ex.label (statt ex.name)
                      Expanded(child: Text(ex.label, style: AppText.body)),
                      // 4. Hier nutzen wir ex.duration als Zahl
                      Text('${ex.duration} Min', style: AppText.caption),
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
          onPressed: () async {
            // Speichert den bereits generierten empfohlenen Plan in Isar
            await planProvider.savePlan(plan);

            // Bringt den Nutzer zurück zur Plan-Übersicht
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
