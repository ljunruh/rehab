import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 7.2 Primary Button.
///
/// sage-Hintergrund, weiß, voll-rund (Radius 24), full-width, Höhe ~50.
/// Pressed → sageMid. Disabled → beige + textMuted.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.disabled = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled || widget.onPressed == null;
    final bg = disabled
        ? AppColors.beige
        : (_down ? AppColors.sageMid : AppColors.sage);
    final fg = disabled ? AppColors.textMuted : AppColors.white;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _down = true),
      onTapUp: disabled ? null : (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.buttonPrimary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: AppIconSize.button, color: fg),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(widget.label, style: AppText.button.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

/// 7.3 Secondary Button.
///
/// Transparent, 1 dp beige-Rahmen, sageDeep-Text, Höhe ~44, Radius 22.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.beige, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppIconSize.button, color: AppColors.sageDeep),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: AppText.button.copyWith(
                color: AppColors.sageDeep,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
