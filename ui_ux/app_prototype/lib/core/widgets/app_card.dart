import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 7.1 Card.
///
/// Weiß, Radius 22, Padding 16–22, kein Schatten. Tap-Feedback:
/// dezenter Scale/Opacity-Puls (hier über InkWell-loses GestureDetector).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color background;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.background = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );

    if (onTap == null) return card;
    return _PressableScale(onTap: onTap!, child: card);
  }
}

/// Dezentes Scale-0.98-Tap-Feedback (StyleGuide §7.1 / §13 Pressed).
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1.0,
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// 7.6 Section Title — 15 dp SemiBold, optionaler Action-Button rechts.
class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionTitle(this.title, {super.key, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: AppText.sectionHeader)),
          if (action != null) action!,
        ],
      ),
    );
  }
}
