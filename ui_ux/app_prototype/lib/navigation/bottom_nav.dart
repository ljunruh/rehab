import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// Die drei Tabs der App-Navigation: Home, Pläne, Verlauf.
/// (Kalender ist über die jeweiligen Screens erreichbar, nicht über die Nav.)
enum AppTab { home, plans, progress }

extension AppTabInfo on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Home';
      case AppTab.plans:
        return 'Pläne';
      case AppTab.progress:
        return 'Verlauf';
    }
  }

  /// Pfad zum SVG-Icon (eure eigenen Grafiken aus assets/icons/navbar).
  String get asset {
    switch (this) {
      case AppTab.home:
        return 'assets/icons/navbar/house.svg';
      case AppTab.plans:
        return 'assets/icons/navbar/notepad.svg';
      case AppTab.progress:
        return 'assets/icons/navbar/arrow.svg';
    }
  }
}

/// Schwebende, abgerundete Bottom-Navigation (nach Design-Vorlage).
///
/// - Aktives Element: grüne Pille (sageLight) mit Icon + Text.
/// - Inaktive Elemente: nur Icon (textMuted eingefärbt).
/// - Rechts ein "+"-Aktionsknopf.
/// Icons sind eure eigenen SVGs, per colorFilter eingefärbt.
class BottomNav extends StatelessWidget {
  final AppTab active;
  final ValueChanged<AppTab> onChange;

  /// Callback für den "+"-Aktionsknopf.
  final VoidCallback? onAddPlan;

  const BottomNav({
    super.key,
    required this.active,
    required this.onChange,
    this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Schwebend: Abstand zu den Seiten und nach unten.
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: const [
            BoxShadow(
              color: AppColors.navShadow,
              offset: Offset(0, 4),
              blurRadius: 18,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(tab: AppTab.home, active: active, onChange: onChange),
            _NavItem(tab: AppTab.plans, active: active, onChange: onChange),
            _NavItem(tab: AppTab.progress, active: active, onChange: onChange),
            if (onAddPlan != null) _AddButton(onTap: onAddPlan!),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppTab tab;
  final AppTab active;
  final ValueChanged<AppTab> onChange;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tab == active;
    final iconColor = isActive ? AppColors.sageDeep : AppColors.textMuted;

    // Der Pfeil (Verlauf) wirkt optisch größer, da das SVG weniger Rand hat
    // → etwas kleiner rendern, damit alle Icons gleich groß wirken.
    final iconSize =
        tab == AppTab.progress ? AppIconSize.nav - 5 : AppIconSize.nav;

    final icon = SvgPicture.asset(
      tab.asset,
      width: iconSize,
      height: iconSize,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChange(tab),
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          // Aktives Element: grüne Pille.
          color: isActive ? AppColors.sageLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            // Text nur beim aktiven Element anzeigen.
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                tab.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sageDeep,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SvgPicture.asset(
          'assets/icons/navbar/plus.svg',
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            AppColors.textMuted,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
