import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Dunkelgrüner Kopfbereich des Home-Screens (Hero).
///
/// sageMid-Hintergrund, Avatar oben rechts, zweizeilige Begrüßung
/// ("Schön, dass du da bist," + Vorname) und der Wochen-Willkommenstext.
/// Entspricht dem grünen Hero im JSX-Prototyp.
class HomeHero extends StatelessWidget {
  final String firstName;
  final String initials;
  final String welcome;
  final VoidCallback onAvatarTap;

  const HomeHero({
    super.key,
    required this.firstName,
    required this.initials,
    required this.welcome,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: AppColors.sageMid,
      padding: EdgeInsets.fromLTRB(24, topInset + 20, 24, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: HeaderAvatar(initials: initials, onTap: onAvatarTap),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Schön, dass du da bist,',
            style: AppText.greeting.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            firstName,
            style: AppText.greeting.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            welcome,
            style: AppText.caption.copyWith(
              color: const Color(0xB8FFFFFF), // rgba(255,255,255,0.72)
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
