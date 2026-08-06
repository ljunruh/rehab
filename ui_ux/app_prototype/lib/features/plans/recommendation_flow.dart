import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/provider/exercise_provider.dart';
import '../../data/provider/plan_provider.dart';
import '../../data/provider/plan_log_exercise_provider.dart';
import '../../data/provider/user_provider.dart';
import '../../data/enum/body_part.dart';
import '../../data/enum/goal.dart';

/// PERSON 2 — Geführter Empfehlungs-Flow („Plan-Empfehlung erhalten").
///
/// Umsetzung von Sophias Redesign (03.07.26), 3 Schritte — bewusst
/// **single-region** (ein Plan = ein Körperteil + ein Trainingseffekt),
/// passend zum Datenmodell der API-Gruppe (`Plan.region`/`Plan.goal`):
///  1. „Welches Körperteil?" — Kontraindikation & Mobilitätslevel (aus dem
///     Profil) + Körperregion-Akkordeon (Oberkörper/Rumpf/Beine → Körperteile).
///  2. „Was möchtest du erreichen?" — Trainingseffekt + Warnhinweis.
///  3. „Vorschlag für dich" — Plan übernehmen / neu auswählen.
///
/// Die Daten-Anbindung ist UNVERÄNDERT die der API-Gruppe:
/// `ExerciseProvider.loadAll(bodyPart, goal)` →
/// `PlanProvider.generateRecommandedPlan(...)` → `recommendedPlan` →
/// `savePlan` + `PlanLogExerciseProvider.loadTodayLogs`.
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

/// Sophias Körperregion-Gruppierung (Oberkörper/Rumpf/Beine) über das
/// bestehende [BodyPart]-Enum. Rein fürs UI — ändert nichts am Datenmodell.
const Map<String, List<BodyPart>> _kRegionGroups = {
  'Oberkörper': [
    BodyPart.shoulders,
    BodyPart.arms,
    BodyPart.elbows,
    BodyPart.wrists,
    BodyPart.chest,
    BodyPart.back,
    BodyPart.upperBack,
    BodyPart.lowerBack,
    BodyPart.neck,
    BodyPart.spine,
  ],
  'Rumpf': [
    BodyPart.core,
    BodyPart.obliques,
    BodyPart.pelvic,
    BodyPart.glutes,
  ],
  'Beine': [
    BodyPart.hip,
    BodyPart.psoas,
    BodyPart.thighs,
    BodyPart.quadriceps,
    BodyPart.hamstrings,
    BodyPart.knees,
    BodyPart.calves,
    BodyPart.ankles,
  ],
};
const List<String> _kRegionOrder = ['Oberkörper', 'Rumpf', 'Beine'];

class _RecommendationFlowState extends State<RecommendationFlow> {
  int _step = 1;
  BodyPart? _region;
  Goal? _goal;
  String? _expandedRegion;
  bool _disclaimerOk = false;
  bool _infoOpen = false;

  void _back() {
    if (_step == 1) {
      widget.onBack();
    } else {
      setState(() => _step--);
    }
  }

  void _reset() => setState(() {
        _step = 1;
        _region = null;
        _expandedRegion = null;
        _goal = null;
        _disclaimerOk = false;
      });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 110),
      children: [
        AppBackButton(onTap: _back),
        const SizedBox(height: AppSpacing.lg),
        _ProgressBar(step: _step),
        const SizedBox(height: AppSpacing.base),
        Text('SCHRITT $_step VON 3', style: AppText.micro),
        const SizedBox(height: AppSpacing.md),
        if (_step == 1) _buildStep1(context),
        if (_step == 2) _buildStep2(context),
        if (_step == 3) _buildStep3(context),
      ],
    );
  }

  // ── Schritt 1: Körperteil ──────────────────────────────────────
  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welches Körperteil möchtest du trainieren?',
            style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.lg),
        _profileInfoCard(context),
        const SizedBox(height: AppSpacing.lg),
        Text('Körperregion', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        for (final region in _kRegionOrder) _regionTile(region),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Weiter',
          icon: Icons.arrow_forward,
          disabled: _region == null,
          onPressed: _region == null ? null : () => setState(() => _step = 2),
        ),
      ],
    );
  }

  Widget _profileInfoCard(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final kontra = userProvider.injuryLabels.isNotEmpty
        ? userProvider.injuryLabels.join(', ')
        : 'Keine angegeben';
    final level = userProvider.userExists ? userProvider.skillLevelText : '—';

    return AppCard(
      background: AppColors.offwhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KONTRAINDIKATION', style: AppText.micro),
                    const SizedBox(height: 2),
                    Text(kontra, style: AppText.cardTitle),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _infoOpen = !_infoOpen),
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _infoOpen ? AppColors.sageLight : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.beige),
                  ),
                  child: Icon(Icons.info_outline,
                      size: 15,
                      color: _infoOpen
                          ? AppColors.sageDeep
                          : AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.monitor_heart_outlined,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MOBILITÄTSLEVEL', style: AppText.micro),
                  const SizedBox(height: 2),
                  Text(level, style: AppText.cardTitle),
                ],
              ),
            ],
          ),
          if (_infoOpen) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Text(
                'Möchtest du deine Kontraindikation oder dein Mobilitätslevel '
                'ändern? Das geht über „Profil bearbeiten".',
                style: AppText.caption.copyWith(color: AppColors.sageDeep),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _regionTile(String region) {
    final parts = _kRegionGroups[region] ?? const <BodyPart>[];
    final open = _expandedRegion == region;
    final selectedHere = (_region != null && parts.contains(_region))
        ? _region!.label
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          AppCard(
            onTap: () => setState(() => _expandedRegion = open ? null : region),
            child: Row(
              children: [
                Text(region, style: AppText.cardTitle),
                if (selectedHere != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppTag(selectedHere, variant: TagVariant.region),
                ],
                const Spacer(),
                Icon(open ? Icons.expand_less : Icons.chevron_right,
                    size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final p in parts)
                    AppChip(
                      label: p.label,
                      active: _region == p,
                      onTap: () => setState(() => _region = p),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Schritt 2: Trainingseffekt + Warnhinweis ───────────────────
  Widget _buildStep2(BuildContext context) {
    final canProceed = _goal != null && _disclaimerOk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Was möchtest du erreichen?', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            style: AppText.caption,
            children: [
              const TextSpan(text: 'Trainingseffekt für: '),
              TextSpan(
                text: _region?.label ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Trainingseffekt', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final g in Goal.values.where((e) => e != Goal.none))
              AppChip(
                label: g.label,
                active: _goal == g,
                onTap: () => setState(() => _goal = g),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _disclaimerCard(),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Plan vorschlagen',
          icon: Icons.auto_awesome,
          disabled: !canProceed,
          onPressed: !canProceed
              ? null
              : () async {
                  final exerciseProvider = context.read<ExerciseProvider>();
                  final planProvider = context.read<PlanProvider>();
                  setState(() => _step = 3);
                  await exerciseProvider.loadAll(
                      bodyPart: _region!, goal: _goal!);
                  planProvider.generateRecommandedPlan(
                    exerciseProvider.exercises,
                    _region!,
                    _goal!,
                  );
                },
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Zurück',
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _disclaimerCard() {
    return AppCard(
      background: AppColors.offwhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _disclaimerOk = !_disclaimerOk),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _disclaimerOk ? AppColors.sage : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _disclaimerOk ? AppColors.sage : AppColors.beige,
                  width: 1.5,
                ),
              ),
              child: _disclaimerOk
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'ReVia eignet sich für die selbstständige Durchführung von '
              'Reha-Übungen. Bei akuten Verletzungen, nach einer frischen '
              'Operation oder bei starken Schmerzen solltest du die App nicht '
              'verwenden und stattdessen medizinischen Rat einholen. Mit dem '
              'Fortfahren bestätigst du, dass dies auf dich nicht zutrifft.',
              style: AppText.caption,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schritt 3: Vorschlag für dich ──────────────────────────────
  Widget _buildStep3(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final plan = planProvider.recommendedPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vorschlag für dich', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.lg),
        if (plan == null)
          const SizedBox(
            height: 180,
            child: Center(
                child: CircularProgressIndicator(color: AppColors.sage)),
          )
        else ...[
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
                      child: Text('${plan.region.label}-Plan',
                          style: AppText.cardTitle),
                    ),
                    AppTag(plan.goal.label, variant: TagVariant.goal),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                for (final ex in plan.exercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.sage),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: Text(ex.label, style: AppText.body)),
                        Text('${ex.duration} Min', style: AppText.caption),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Plan übernehmen',
            icon: Icons.check,
            onPressed: () async {
              final pp = context.read<PlanProvider>();
              final ple = context.read<PlanLogExerciseProvider>();
              await pp.savePlan(plan);
              await ple.loadTodayLogs(activePlans: pp.activePlans);
              if (context.mounted) widget.onSaved();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Nicht übernehmen · Neu auswählen',
            onPressed: _reset,
          ),
        ],
      ],
    );
  }
}

/// Fortschrittsbalken mit 3 Segmenten.
class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int s = 1; s <= 3; s++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: s <= step ? AppColors.sage : AppColors.beige,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (s < 3) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
