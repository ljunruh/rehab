import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// PERSON 1 — Detailansicht einer Übung.
///
/// Zeigt Video-Platzhalter, Tags, Beschreibung, Schritt-für-Schritt-Anleitung,
/// Sicherheitshinweise und die Aktion "Als erledigt markieren".
/// Entspricht ExerciseDetail im JSX-Prototyp.
class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;
  final VoidCallback onBack;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.onBack,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final exercise = app.exerciseById(widget.exerciseId);

    if (exercise == null) {
      return Center(
        child: Text('Übung nicht gefunden.', style: AppText.body),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        110,
      ),
      children: [
        AppBackButton(onTap: widget.onBack),
        const SizedBox(height: AppSpacing.base),

        _VideoPlaceholder(
          playing: _playing,
          durationSec: exercise.durationSec ?? exercise.duration,
          onTap: () => setState(() => _playing = !_playing),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(exercise.name, style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _MetaTag(exercise.region),
            _MetaTag(exercise.duration),
            _MetaTag(exercise.difficulty),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(exercise.description, style: AppText.body),
        const SizedBox(height: AppSpacing.xl),

        const SectionTitle('Schritt für Schritt'),
        AppCard(
          child: Column(
            children: [
              for (int i = 0; i < exercise.steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == exercise.steps.length - 1 ? 0 : 14,
                  ),
                  child: _StepRow(index: i + 1, text: exercise.steps[i]),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        const SectionTitle('Sicherheitshinweise'),
        AppCard(
          background: AppColors.offwhite,
          child: Column(
            children: [
              for (int i = 0; i < exercise.safety.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == exercise.safety.length - 1 ? 0 : 10,
                  ),
                  child: _SafetyRow(text: exercise.safety[i]),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        if (exercise.done)
          _DoneBanner()
        else
          PrimaryButton(
            label: 'Als erledigt markieren',
            icon: Icons.check,
            onPressed: () {
              app.completeExercise(exercise.id);
              widget.onBack();
            },
          ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(label: 'Zurück', onPressed: widget.onBack),
      ],
    );
  }
}

/// Video-Platzhalter (Verlauf mint → sageLight, Play/Pause-Button).
class _VideoPlaceholder extends StatelessWidget {
  final bool playing;
  final String durationSec;
  final VoidCallback onTap;

  const _VideoPlaceholder({
    required this.playing,
    required this.durationSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            children: [
              // Verlaufshintergrund
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.mint, AppColors.sageLight],
                  ),
                ),
              ),
              // Dekorative Kreise
              Positioned(
                top: -30,
                right: -20,
                child: _Circle(120, const Color(0x40FFFFFF)),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: _Circle(100, const Color(0x26FFFFFF)),
              ),
              // Play/Pause
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.avatarShadow,
                        offset: Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: AppColors.sageDeep,
                    size: 30,
                  ),
                ),
              ),
              // Label oben links
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xD9FFFFFF),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    playing ? 'Video läuft' : 'Video ansehen',
                    style: AppText.label.copyWith(
                      color: AppColors.sageDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Dauer unten rechts
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xA61F2421),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule,
                          size: 11, color: AppColors.white),
                      const SizedBox(width: 5),
                      Text(
                        durationSec,
                        style: AppText.label.copyWith(
                          color: AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _MetaTag extends StatelessWidget {
  final String label;
  const _MetaTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.beige, width: 1),
      ),
      child: Text(label,
          style: AppText.label.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  const _StepRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: AppText.label.copyWith(
              color: AppColors.sageDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(text, style: AppText.body),
          ),
        ),
      ],
    );
  }
}

class _SafetyRow extends StatelessWidget {
  final String text;
  const _SafetyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.alertSoft,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.body)),
      ],
    );
  }
}

class _DoneBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(AppRadius.buttonPrimary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check, size: 18, color: AppColors.sageDeep),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Bereits erledigt',
            style: AppText.cardTitle.copyWith(color: AppColors.sageDeep),
          ),
        ],
      ),
    );
  }
}
