import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// "Tipp für heute"-Karte mit drei internen Zuständen, wie im
/// JSX-Prototyp (`TipOfDayCard`, Zustand startet immer bei "locked"):
///  1. locked: Schloss zu, "Noch gesperrt" + Freischalt-Hinweis.
///  2. unlocked: Schloss offen, Titel + Dauer + Pfeil rechts.
///  3. open: Schloss offen, Titel + Dauer + Pfeil unten, darunter der
///     Tipp-Text.
///
/// WICHTIG: Der Zustand hängt NICHT von echten Trainings-Sessions ab
/// (im Prototyp ist das ein hart codiertes `useState("locked")`, das
/// rein durch Antippen weitergeschaltet wird — kein Backend-Bezug).
/// Tippen: locked→unlocked, unlocked→open, open→unlocked (togglet).
class TipOfDayCard extends StatefulWidget {
  final String title;
  final String duration;
  final String body;

  const TipOfDayCard({
    super.key,
    required this.title,
    required this.duration,
    required this.body,
  });

  @override
  State<TipOfDayCard> createState() => _TipOfDayCardState();
}

enum _TipPhase { locked, unlocked, open }

class _TipOfDayCardState extends State<TipOfDayCard> {
  _TipPhase _phase = _TipPhase.locked;

  void _handleTap() {
    setState(() {
      switch (_phase) {
        case _TipPhase.locked:
          _phase = _TipPhase.unlocked;
          break;
        case _TipPhase.open:
          _phase = _TipPhase.unlocked;
          break;
        case _TipPhase.unlocked:
          _phase = _TipPhase.open;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locked = _phase == _TipPhase.locked;
    final open = _phase == _TipPhase.open;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.sageDeep,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kopfzeile
            Row(
              children: [
                // Icon-Kachel
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.onDarkIconBg,
                    borderRadius: BorderRadius.circular(AppRadius.iconLarge),
                  ),
                  child: Icon(
                    open ? Icons.lock_open : Icons.lock_outline,
                    size: 22,
                    color: locked
                        ? const Color(0xB3FFFFFF)
                        : AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locked ? 'Noch gesperrt' : widget.title,
                        style:
                            AppText.cardTitle.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        locked
                            ? 'Schließe heute einen Plan ab, um deinen Tipp freizuschalten.'
                            : widget.duration,
                        style: AppText.caption
                            .copyWith(color: AppColors.onDarkSecondary),
                      ),
                    ],
                  ),
                ),
                // Pfeil (nur wenn nicht gesperrt): rechts = zu, unten = offen
                if (!locked) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    open ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    size: 20,
                    color: const Color(0x80FFFFFF),
                  ),
                ],
              ],
            ),

            // Aufgeklappter Text (Zustand "open")
            if (open) ...[
              const SizedBox(height: AppSpacing.base),
              Divider(color: AppColors.onDarkDivider, height: 1),
              const SizedBox(height: AppSpacing.base),
              Text(
                widget.body,
                style: AppText.body.copyWith(
                  color: AppColors.white,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
