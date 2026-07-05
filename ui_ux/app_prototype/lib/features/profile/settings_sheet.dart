import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../state/ui_state.dart';
import 'package:provider/provider.dart';

/// "Einstellungen"-Sheet im Profil-Drawer (Person 4).
///
/// Entspricht dem `settingsOpen`-Sheet im JSX-Prototyp: Abschnitt
/// "Rechtliches" mit Datenschutz und Lizenzen (reine Navigationszeilen,
/// im Prototyp ohne Aktion — hier als Toast, da kein echtes Backend/keine
/// echten Rechtstexte hinterlegt sind).
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

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
      builder: (_) => const SettingsSheet(),
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
              Text('Einstellungen',
                  style: AppText.screenTitle.copyWith(fontSize: 18)),
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
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text('RECHTLICHES', style: AppText.micro),
          const SizedBox(height: AppSpacing.sm),
          _SettingsRow(
            icon: 'assets/icons/profile/shield.svg',
            label: 'Datenschutz',
            isFirst: true,
            onTap: () => context
                .read<UiState>()
                .showToast('Datenschutzerklärung (Demo).'),
          ),
          const SizedBox(height: 2),
          _SettingsRow(
            icon: 'assets/icons/profile/info-green.svg',
            label: 'Lizenzen',
            isLast: true,
            onTap: () =>
                context.read<UiState>().showToast('Lizenzen (Demo).'),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String icon; // SVG-Asset-Pfad
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.offwhite,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(14) : const Radius.circular(4),
            bottom: isLast ? const Radius.circular(14) : const Radius.circular(4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(9),
              ),
              child: SvgPicture.asset(icon,
                  width: 14, height: 14,
                  colorFilter: const ColorFilter.mode(
                      AppColors.sageDeep, BlendMode.srcIn)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppText.cardTitle.copyWith(
                      fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right,
                size: 15, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
