import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Schmerzskala-Erklärung (Bottom-Sheet).
///
/// Öffnet sich über das Info-Icon der Schmerz-Karte und erklärt die
/// numerische Skala von 0 (kein Schmerz) bis 10 (stärkster Schmerz).
/// Entspricht dem Schmerzskala-Sheet im JSX-Prototyp.
class PainScaleSheet extends StatelessWidget {
  const PainScaleSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => const PainScaleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levels = <_Level>[
      _Level('0', 'Kein Schmerz', 'Du spürst überhaupt nichts.',
          AppColors.sageLight),
      _Level('1–3', 'Leichter Schmerz',
          'Bemerkbar, aber gut auszuhalten – stört dich im Alltag kaum.',
          AppColors.mint),
      _Level('4–6', 'Mittlerer Schmerz',
          'Deutlich spürbar, beeinflusst Bewegungen oder Konzentration.',
          AppColors.sageLight),
      _Level('7–9', 'Starker Schmerz',
          'Belastend, schwer zu ignorieren – Aktivitäten fallen schwer.',
          AppColors.alertSoft),
      _Level('10', 'Stärkster Schmerz',
          'Unerträglich, du brauchst dringend Linderung.',
          AppColors.alertSoft),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Schmerzskala',
                    style: AppText.screenTitle.copyWith(fontSize: 22)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                    ),
                    child:
                        const Icon(Icons.close, size: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Die numerische Schmerzskala hilft dir, dein Schmerzempfinden '
              'einzuordnen. Sie reicht von 0 (kein Schmerz) bis 10 '
              '(stärkster vorstellbarer Schmerz).',
              style: AppText.body.copyWith(
                  color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final l in levels) ...[
              _LevelRow(level: l),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _Level {
  final String range;
  final String title;
  final String desc;
  final Color color;
  const _Level(this.range, this.title, this.desc, this.color);
}

class _LevelRow extends StatelessWidget {
  final _Level level;
  const _LevelRow({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: level.color,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Text(level.range,
                style: AppText.cardTitle.copyWith(color: AppColors.sageDeep)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.title, style: AppText.cardTitle),
                const SizedBox(height: 2),
                Text(level.desc,
                    style: AppText.caption.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
