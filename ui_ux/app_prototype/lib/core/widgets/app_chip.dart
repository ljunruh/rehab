import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 7.4 Chip / Filter Tag.
///
/// Aktiv: sageLight-Hintergrund, sageDeep-Text, kein Rahmen.
/// Inaktiv: offwhite-Hintergrund, textSecondary-Text, 1 dp beige-Rahmen.
/// Pill-Radius, Spring-Animation beim Aktivieren (StyleGuide §9).
class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.screenEntry,
        curve: AppMotion.spring,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.sageLight : AppColors.offwhite,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: active
              ? null
              : Border.all(color: AppColors.beige, width: 1),
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(
            color: active ? AppColors.sageDeep : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 7.5 Tag / Badge (read-only).
///
/// Varianten aus dem StyleGuide. Alle Tags: 12 dp Medium, Pill-Radius.
enum TagVariant { region, goal, source, planColor }

class AppTag extends StatelessWidget {
  final String label;
  final TagVariant variant;

  /// Nur bei [TagVariant.planColor] genutzt (Hintergrund = Plan-Farbe).
  final Color? planColor;

  const AppTag(
    this.label, {
    super.key,
    this.variant = TagVariant.region,
    this.planColor,
  });

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    switch (variant) {
      case TagVariant.region:
        bg = AppColors.sageLight;
        fg = AppColors.sageDeep;
        break;
      case TagVariant.goal:
        bg = AppColors.mint;
        fg = AppColors.sageDeep;
        break;
      case TagVariant.source:
        bg = AppColors.beige;
        fg = AppColors.textSecondary;
        break;
      case TagVariant.planColor:
        bg = planColor ?? AppColors.sage;
        fg = AppColors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppText.label.copyWith(color: fg)),
    );
  }
}
