import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// PERSON 2 — Auswahl-Sheet beim Anlegen eines neuen Plans.
///
/// Zwei Optionen: "Plan-Empfehlung erhalten" (geführt) oder
/// "Eigenen Plan erstellen" (manueller Wizard). Erscheint als Bottom-Sheet,
/// wenn der "+"-Knopf in der Navigation getippt wird.
/// Entspricht NewPlanChoiceSheet im JSX-Prototyp.
class NewPlanChoiceSheet extends StatelessWidget {
  final VoidCallback onRecommend;
  final VoidCallback onManual;

  const NewPlanChoiceSheet({
    super.key,
    required this.onRecommend,
    required this.onManual,
  });

  /// Komfort-Methode: zeigt das Sheet modal an.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRecommend,
    required VoidCallback onManual,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => NewPlanChoiceSheet(
        onRecommend: onRecommend,
        onManual: onManual,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greifer
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
              Text('Neuen Plan erstellen', style: AppText.screenTitle.copyWith(fontSize: 20)),
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
                  child: const Icon(Icons.close, size: 16, color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Wähle, wie du deinen neuen Trainingsplan zusammenstellen möchtest.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Option 1: Empfehlung
          _ChoiceCard(
            icon: Icons.auto_awesome,
            iconBg: AppColors.white,
            background: AppColors.sageLight,
            title: 'Plan-Empfehlung erhalten',
            subtitle: 'Beantworte ein paar Fragen und erhalte einen passenden Plan.',
            titleColor: AppColors.sageDeep,
            onTap: () {
              Navigator.of(context).pop();
              onRecommend();
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Option 2: Eigener Plan
          _ChoiceCard(
            icon: Icons.edit_outlined,
            iconBg: AppColors.mint,
            background: AppColors.white,
            title: 'Eigenen Plan erstellen',
            subtitle: 'Stelle deinen Plan manuell aus Übungen zusammen.',
            titleColor: AppColors.text,
            onTap: () {
              Navigator.of(context).pop();
              onManual();
            },
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color background;
  final String title;
  final String subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.iconBg,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      background: background,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.iconLarge),
            ),
            child: Icon(icon, size: 20, color: AppColors.sageDeep),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppText.cardTitle.copyWith(color: titleColor)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
