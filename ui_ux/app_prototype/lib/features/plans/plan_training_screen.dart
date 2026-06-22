import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// PERSON 2 — Trainings-Durchlauf eines Plans.
///
/// Führt Schritt für Schritt durch die Übungen, erfasst optional ein
/// Schmerzlevel (0–10) pro Übung und zeigt am Ende einen Abschluss-Screen.
/// Entspricht PlanTraining im JSX-Prototyp.
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

  Color _painColor(int v) {
    if (v >= 7) return const Color(0xFFC5705D);
    if (v >= 4) return const Color(0xFFC99A3B);
    return AppColors.sage;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final plan = app.planById(widget.planId);
    if (plan == null) {
      return Center(child: Text('Plan nicht gefunden.', style: AppText.body));
    }

    final exercises = <Exercise>[];
    for (final id in plan.exerciseIds) {
      for (final e in app.library) {
        if (e.id == id) {
          exercises.add(e);
          break;
        }
      }
    }

    if (exercises.isEmpty) {
      return Center(
        child: Text('Dieser Plan enthält keine Übungen.', style: AppText.body),
      );
    }

    if (_done) {
      return _CompletionView(
        exerciseCount: exercises.length,
        onFinish: widget.onFinish,
      );
    }

    final current = exercises[_idx];
    final isLast = _idx == exercises.length - 1;
    final pain = _painLevels[_idx];

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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.close, size: 18, color: AppColors.text),
              ),
            ),
            Text(
              '${_idx + 1} von ${exercises.length}',
              style: AppText.label.copyWith(color: AppColors.textSecondary),
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
        const SizedBox(height: AppSpacing.xl),

        // Visual
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mint, AppColors.sageLight],
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: const Center(
              child: Icon(Icons.self_improvement,
                  size: 48, color: AppColors.sageDeep),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(current.name, style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(current.description, style: AppText.body),
        const SizedBox(height: AppSpacing.lg),

        // Schritte
        const SectionTitle('Schritt für Schritt'),
        AppCard(
          child: Column(
            children: [
              for (int i = 0; i < current.steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == current.steps.length - 1 ? 0 : 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.sageLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text('${i + 1}',
                            style: AppText.label
                                .copyWith(color: AppColors.sageDeep)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(current.steps[i], style: AppText.body)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Schmerz-Erfassung
        const SectionTitle('Wie fühlt sich die Übung an?'),
        AppCard(
          background: AppColors.offwhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pain == null
                    ? 'Optional: Schmerzlevel angeben'
                    : 'Schmerzlevel: $pain von 10',
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(11, (level) {
                  final selected = pain == level;
                  return GestureDetector(
                    onTap: () => setState(() => _painLevels[_idx] = level),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? _painColor(level) : AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                        border: Border.all(
                          color: selected ? _painColor(level) : AppColors.beige,
                        ),
                      ),
                      child: Text(
                        '$level',
                        style: AppText.label.copyWith(
                          color: selected ? AppColors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              if (pain != null && pain >= 7) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.alertSoft.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Text(
                    'Bei starken Schmerzen: Übung abbrechen und ggf. mit deiner '
                    'Therapeutin sprechen.',
                    style: AppText.caption.copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        PrimaryButton(
          label: isLast ? 'Training abschließen' : 'Nächste Übung',
          icon: isLast ? Icons.check : Icons.arrow_forward,
          onPressed: () => _handleNext(app, current, isLast),
        ),
      ],
    );
  }

  void _handleNext(UiState app, Exercise current, bool isLast) {
    final pain = _painLevels[_idx];
    if (pain != null) {
      final now = DateTime.now();
      app.addPainLog(PainLog(
        level: pain,
        region: current.region,
        note: '',
        date: now,
        dateKey: PainLog.keyOf(now),
      ));
    }
    if (isLast) {
      setState(() => _done = true);
    } else {
      setState(() => _idx += 1);
    }
  }
}

/// Abschluss-Screen nach dem letzten Schritt.
class _CompletionView extends StatelessWidget {
  final int exerciseCount;
  final VoidCallback onFinish;

  const _CompletionView({
    required this.exerciseCount,
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
                Text('$exerciseCount Übungen',
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
