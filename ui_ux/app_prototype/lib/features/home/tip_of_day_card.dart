import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// "Tipp für heute"-Card auf dunkler Fläche (StyleGuide §12 Dark Surface).
///
/// Zwei Zustände:
///  - gesperrt (locked): großes Schloss-Icon, "Noch gesperrt" +
///    Freischalt-Hinweis. Tippen schaltet frei (onTap).
///  - frei: Glühbirnen-Icon, Tipp-Titel + Teaser, Chevron rechts.
/// Entspricht TipOfDayCard im JSX-Prototyp (ohne API-Aufruf).
class TipOfDayCard extends StatelessWidget {
  final String title;
  final String body;
  final bool locked;
  final VoidCallback? onTap;

  const TipOfDayCard({
    super.key,
    required this.title,
    required this.body,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.sageDeep,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            // Großes Icon links
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.onDarkIconBg,
                borderRadius: BorderRadius.circular(AppRadius.iconLarge),
              ),
              child: Icon(
                locked ? Icons.lock_outline : Icons.lightbulb_outline,
                size: 22,
                color: locked ? const Color(0xB3FFFFFF) : AppColors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locked ? 'Noch gesperrt' : title,
                    style: AppText.cardTitle.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    locked
                        ? 'Schließe heute einen Plan ab, um deinen Tipp freizuschalten.'
                        : body,
                    style: AppText.caption
                        .copyWith(color: AppColors.onDarkSecondary),
                  ),
                ],
              ),
            ),
            if (!locked) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0x80FFFFFF)),
            ],
          ],
        ),
      ),
    );
  }
}
