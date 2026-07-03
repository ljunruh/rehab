import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/widgets.dart';

/// 10.2 Screen Header.
///
/// Zeile: Begrüßungstext (links) + Avatar-Button (rechts).
/// Hintergrund = cream (keine Card). Padding 20 horizontal · 16 vertikal.
class ScreenHeader extends StatelessWidget {
  final String greeting;
  final String? subtitle;
  final String initials;
  final VoidCallback? onAvatarTap;

  const ScreenHeader({
    super.key,
    required this.greeting,
    required this.initials,
    this.subtitle,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.base,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppText.greeting),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppText.headerSub),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          HeaderAvatar(initials: initials, onTap: onAvatarTap),
        ],
      ),
    );
  }
}
