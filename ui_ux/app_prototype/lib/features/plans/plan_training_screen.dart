import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:app_prototype/data/models/api/api_models.dart' as api;
import 'package:app_prototype/data/provider/pain_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/features/plans/plan_training_video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../state/ui_state.dart';

/// PERSON 2 — Trainings-Durchlauf eines Plans.
///
/// Führt Schritt für Schritt durch die Übungen, erfasst optional ein
/// Schmerzlevel (0–10) pro Übung und zeigt am Ende einen Abschluss-Screen.
/// Entspricht PlanTraining im JSX-Prototyp (V12) — inkl. Info-Toggle,
/// aufklappbarer Ausführung/Korrekturen, aufklappbarem Schmerz-Logging,
/// Warnkarte bei starken Schmerzen und Zurück/Überspringen-Zeile.
class PlanTrainingScreen extends StatefulWidget {
  final String planId;
  final VoidCallback onExit;

  /// Aufgerufen, wenn das Training abgeschlossen wurde (zählt Session hoch).
  final VoidCallback onFinish;

  const PlanTrainingScreen({
    super.key,
    required this.planId,
    required this.onExit,
    required this.onFinish,
  });

  @override
  State<PlanTrainingScreen> createState() => _PlanTrainingScreenState();
}

class _PlanTrainingScreenState extends State<PlanTrainingScreen> {
  int _idx = 0;
  bool _done = false;
  final Map<int, int> _painLevels = {}; // Übungsindex -> Schmerzlevel
  bool _painOpen = false;
  bool _infoOpen = false;
  bool _stepsOpen = true;
  bool _safetyOpen = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().getPlan(widget.planId);
    });
  }

  Color _painColor(int v) {
    if (v >= 7) return const Color(0xFFC5705D);
    if (v >= 4) return const Color(0xFFC99A3B);
    return AppColors.sage;
  }

  /*
  int _planDuration(TrainingPlan plan, UiState app) {
    var total = 0;
    for (final id in plan.exerciseIds) {
      for (final e in app.library) {
        if (e.id == id) {
          total += int.tryParse(e.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          break;
        }
      }
    }
    return total;
  }
  */

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final planProvider = context.watch<PlanProvider>();
    final plan = planProvider.plan;
    final exercises = plan?.exercises ?? [];
    final planDuration = plan?.duration ?? 0;


    //final plan = app.planById(widget.planId);
    if (plan == null) {
      return Center(child: Text('Plan nicht gefunden.', style: AppText.body));
    }

    // UI DemoData auskommentieren
    // Übungen des Plans aus der Bibliothek auflösen (in exerciseIds-Reihenfolge).
    /*
    final exercises = <Exercise>[];
    for (final id in plan.exerciseIds) {
      for (final e in app.library) {
        if (e.id == id) {
          exercises.add(e);
          break;
        }
      }
    }
    */

    if (exercises.isEmpty) {
      return Center(
        child: Text('Dieser Plan enthält keine Übungen.', style: AppText.body),
      );
    }

    if (_done) {
      return _CompletionView(
        exerciseCount: exercises.length,
        duration: planDuration,
        onFinish: widget.onFinish,
      );
    }

    final api.Exercise current = exercises[_idx];
    final isLast = _idx == exercises.length - 1;
    final pain = _painLevels[_idx];
    final severe = pain != null && pain >= 7;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        110,
      ),
      children: [
        // Kopf: Abbrechen + Zähler
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.onExit,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.close, size: 18, color: AppColors.text),
              ),
            ),
            Text(
              '${_idx + 1} von ${exercises.length}',
              style: AppText.caption.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Fortschrittsbalken
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (_idx + 1) / exercises.length,
            minHeight: 4,
            backgroundColor: AppColors.beige,
            valueColor: const AlwaysStoppedAnimation(AppColors.sage),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Visual-Hero mit Play-Button und Dauer-Badge
        PlanTrainingVideoWidget(assetPath: current.video, key: ValueKey(current.id)),
        const SizedBox(height: AppSpacing.lg),

        // Titel + Info-Toggle
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(current.label,
                  style: AppText.screenTitle.copyWith(fontSize: 24)),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => setState(() => _infoOpen = !_infoOpen),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _infoOpen ? AppColors.sageLight : AppColors.offwhite,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                    _infoOpen
                        ? 'assets/icons/other/info-green.svg'
                        : 'assets/icons/other/info-gray.svg',
                    width: 13, height: 13),
              ),
            ),
          ],
        ),
        if (_infoOpen) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(current.description,
              style: AppText.caption.copyWith(height: 1.6)),
        ],
        const SizedBox(height: AppSpacing.md),

        // Region- & Schwierigkeits-Tags
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _Pill(BodyPartExt.fromString(current.bodyParts[0]).label), //TODO[API]: Magic Number -> Prüfen ob hier aktuell immer nur ein BodyPart steht
            _Pill(SkillLevelExt.fromString(current.difficulty).label),
          ],
        ),
        const SizedBox(height: AppSpacing.base),

        // Ausführung (Schritte) – aufklappbar
        if (current.instructions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _stepsOpen = !_stepsOpen),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AUSFÜHRUNG', style: AppText.micro),
                        AnimatedRotation(
                          turns: _stepsOpen ? 0.25 : 0,
                          duration: AppMotion.standard,
                          child: const Icon(Icons.chevron_right,
                              size: 14, color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                  if (_stepsOpen) ...[
                    const SizedBox(height: AppSpacing.sm),
                    for (int i = 0; i < current.instructions.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              i == current.instructions.length - 1 ? 0 : AppSpacing.sm,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.sage,
                                shape: BoxShape.circle,
                              ),
                              child: Text('${i + 1}',
                                  style: AppText.micro.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(current.instructions[i],
                                  style: AppText.caption
                                      .copyWith(color: AppColors.text, height: 1.55)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),

        // Korrekturen & Hinweise – aufklappbar, warme Farbe
        if (current.instructions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF6F3),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: const Color(0xFFEDD5C8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _safetyOpen = !_safetyOpen),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('KORREKTUREN & HINWEISE',
                            style: AppText.micro
                                .copyWith(color: const Color(0xFFA05B45))),
                        AnimatedRotation(
                          turns: _safetyOpen ? 0.25 : 0,
                          duration: AppMotion.standard,
                          child: const Icon(Icons.chevron_right,
                              size: 14, color: Color(0xFFA05B45)),
                        ),
                      ],
                    ),
                  ),
                  if (_safetyOpen) ...[
                    const SizedBox(height: AppSpacing.sm),
                    for (int i = 0; i < current.hints.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == current.hints.length - 1
                              ? 0
                              : AppSpacing.sm,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC47A5A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(current.hints[i],
                                  style: AppText.caption.copyWith(
                                      color: const Color(0xFF8F4631),
                                      height: 1.55)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),

        // Optionales Schmerz-Logging – aufklappbarer Header
        Padding(
          padding: EdgeInsets.only(bottom: severe ? AppSpacing.sm : AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _painOpen = !_painOpen),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.beige),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/other/electrocardiogram.svg',
                          width: 16, height: 16,
                          colorFilter: const ColorFilter.mode(
                              AppColors.sageDeep, BlendMode.srcIn)),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Schmerzen dabei?',
                          style: AppText.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.text)),
                      const SizedBox(width: 6),
                      Text('optional',
                          style: AppText.micro),
                      const Spacer(),
                      if (pain != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.beige),
                          ),
                          child: Text('$pain/10',
                              style: AppText.micro.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _painColor(pain))),
                        ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: _painOpen ? 0.25 : 0,
                        duration: AppMotion.standard,
                        child: const Icon(Icons.chevron_right,
                            size: 17, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              if (_painOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (int v = 0; v <= 10; v++) ...[
                            if (v > 0) const SizedBox(width: 5),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _painLevels[_idx] = v),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: pain == v
                                          ? _painColor(v)
                                          : AppColors.offwhite,
                                      borderRadius:
                                          BorderRadius.circular(9),
                                      border: pain == v
                                          ? null
                                          : Border.all(
                                              color: AppColors.beige),
                                    ),
                                    child: Text('$v',
                                        style: AppText.micro.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: pain == v
                                              ? AppColors.white
                                              : AppColors.textSecondary,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('kein Schmerz', style: AppText.micro),
                          Text('sehr stark', style: AppText.micro),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Warnkarte bei starken Schmerzen
        if (severe)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEDE8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8C7BC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        size: 17, color: Color(0xFFB5573F)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lieber pausieren',
                            style: AppText.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8F4631))),
                        const SizedBox(height: 3),
                        Text(
                          'Bei so starken Schmerzen brich die Übung lieber ab '
                          'und sprich mit deinem Physio, bevor du weitermachst.',
                          style: AppText.micro.copyWith(
                              color: const Color(0xFFA05B45), height: 1.5),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => app.showToast(
                              'Nachricht an die Praxis (Demo).'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5573F),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.medical_services_outlined,
                                    size: 14, color: AppColors.white),
                                const SizedBox(width: 6),
                                Text('Physio kontaktieren',
                                    style: AppText.micro.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        PrimaryButton(
          label: isLast
              ? 'Übung erledigt – Plan abschließen'
              : 'Übung erledigt · Weiter',
          icon: isLast ? Icons.check : Icons.arrow_forward,
          onPressed: () => _handleNext(plan.id, current, isLast),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            if (_idx > 0) ...[
              Expanded(
                child: SecondaryButton(
                  label: 'Zurück',
                  icon: Icons.chevron_left,
                  onPressed: () => setState(() {
                    _idx -= 1;
                    _stepsOpen = true;
                    _safetyOpen = true;
                    _infoOpen = false;
                    _painOpen = false;
                  }),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: SecondaryButton(
                //TODO: Fehlt -> Wenn Pausieren gedrückt wird, dann Training schließen und zurück zur Planübersicht
                label: isLast ? 'Pausieren' : 'Überspringen',
                onPressed: () {
                  if (_idx < exercises.length - 1) {
                    setState(() {
                      _idx += 1;
                      _stepsOpen = true;
                      _safetyOpen = true;
                      _infoOpen = false;
                      _painOpen = false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleNext(String planId, api.Exercise current, bool isLast) {
    setState(() {
      _painOpen = false;
      _infoOpen = false;
      _stepsOpen = true;
      _safetyOpen = true;
    });
    final pain = _painLevels[_idx];
    if (pain != null) {
      final now = DateTime.now();
      context.read<PainLogExerciseProvider>().addPainLog(
        level: pain,
        region: BodyPartExt.fromString(current.bodyParts[0]), //TODO[API]: Magic Number -> Prüfen ob hier aktuell immer nur ein BodyPart steht
        date: now,
        planId: planId,
        exerciseId: current.id
      );
    }

    context.read<PlanLogExerciseProvider>().logExercise(
      planId: planId,
      exerciseId: current.id,
    );
    if (isLast) {
      context.read<PlanProvider>().incrementCompletedSessions(planId);
      setState(() => _done = true);
    } else {
      setState(() => _idx += 1);
    }
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.beige),
      ),
      child: Text(label,
          style: AppText.caption.copyWith(color: AppColors.textSecondary)),
    );
  }
}

/// Abschluss-Screen nach dem letzten Schritt.
class _CompletionView extends StatelessWidget {
  final int exerciseCount;
  final int duration;
  final VoidCallback onFinish;

  const _CompletionView({
    required this.exerciseCount,
    required this.duration,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 60, AppSpacing.xl, 110),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppColors.sageLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 42, color: AppColors.sageDeep),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Training abgeschlossen',
              style: AppText.screenTitle, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Stark gemacht — dein Plan wurde gespeichert.',
            style: AppText.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            background: AppColors.offwhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GESCHAFFT', style: AppText.micro),
                const SizedBox(height: 4),
                Text('$exerciseCount Übungen · $duration Min',
                    style: AppText.cardTitle.copyWith(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Zurück zu meinen Plänen',
            icon: Icons.arrow_forward,
            onPressed: onFinish,
          ),
        ],
      ),
    );
  }
}
