import 'package:app_prototype/data/models/api/recipe.dart';
import 'package:app_prototype/data/provider/recipe_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';

/// "Vergangene Tages-Tipps" als Historie freigeschalteter Wochen-Rezepte.
class PastTipsSheet extends StatelessWidget {
  const PastTipsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => const PastTipsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<RecipeProvider>().history;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.base,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
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
                Text(
                  'Vergangene Tages-Tipps',
                  style: AppText.screenTitle.copyWith(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.offwhite,
                      borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                    ),
                    child: const Icon(Icons.close, size: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hier findest du alle freigeschalteten Wochen-Rezepte, sortiert nach Freischaltdatum.',
              style: AppText.caption.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.base),
            if (history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  'Noch keine Einträge. Schließe eine neue Streak-Woche ab, um ein Rezept freizuschalten.',
                  style: AppText.caption,
                ),
              )
            else
              for (final recipe in history) _RecipeHistoryCard(recipe: recipe),
          ],
        ),
      ),
    );
  }
}

class _RecipeHistoryCard extends StatefulWidget {
  final Recipe recipe;

  const _RecipeHistoryCard({required this.recipe});

  @override
  State<_RecipeHistoryCard> createState() => _RecipeHistoryCardState();
}

class _RecipeHistoryCardState extends State<_RecipeHistoryCard> {
  bool _open = false;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant_menu, size: 16, color: AppColors.sageDeep),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FREIGESCHALTET ${_formatDate(recipe.unlockedAt)}', style: AppText.micro),
                          const SizedBox(height: 2),
                          Text(recipe.displayTitle, style: AppText.cardTitle.copyWith(height: 1.3)),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.25 : 0,
                      duration: AppMotion.standard,
                      child: const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (_open)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zubereitungszeit: ${recipe.displayDuration}', style: AppText.caption),
                      const SizedBox(height: AppSpacing.sm),
                      Text(recipe.hasDescription, style: AppText.body.copyWith(height: 1.5)),
                      const SizedBox(height: AppSpacing.md),
                      Text('Gesundheitsvorteil', style: AppText.cardTitle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(recipe.hasHealthBenefit, style: AppText.caption.copyWith(height: 1.55)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
