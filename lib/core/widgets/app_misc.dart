import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 7.7 Back Button.
///
/// 40×40, weiß, Radius 14, ChevronLeft 20 dp. 18 dp Abstand zum Inhalt
/// regelt der aufrufende Screen.
class AppBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const AppBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: const Icon(Icons.chevron_left,
            size: 20, color: AppColors.text),
      ),
    );
  }
}

/// 7.8 Header Avatar.
///
/// 36×36, sageLight, Kreis, Initialen 14 dp SemiBold sageDeep.
class HeaderAvatar extends StatelessWidget {
  final String initials;
  final VoidCallback? onTap;

  const HeaderAvatar({super.key, required this.initials, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.sageLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.avatarShadow,
              offset: Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: Text(
          initials,
          style: AppText.cardTitle.copyWith(color: AppColors.sageDeep),
        ),
      ),
    );
  }
}

/// 7.9 Toast / Snackbar.
///
/// sageDeep-Hintergrund, weißer Text + Check-Icon, Radius 16,
/// 100 dp über der Nav, 2400 ms Auto-Dismiss.
///
/// Wird typischerweise als Overlay im Scaffold gestapelt; zeigt sich,
/// solange [message] gesetzt ist. Das Auto-Dismiss steuert der Aufrufer
/// (z.B. UiState.clearToast nach AppMotion.toastDuration).
class AppToast extends StatelessWidget {
  final String message;
  const AppToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: 100,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.sageDeep,
            borderRadius: BorderRadius.circular(AppRadius.toast),
            boxShadow: const [
              BoxShadow(
                color: AppColors.toastShadow,
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 16, color: AppColors.white),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  message,
                  style: AppText.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
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
