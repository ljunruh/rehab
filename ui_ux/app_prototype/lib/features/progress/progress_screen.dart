import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../navigation/screen_header.dart';
import '../home/concentric_rings.dart';
import 'calendar_widget.dart';
import 'pain_history_carousel.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 3 — VERLAUF & KALENDER (wie Prototyp)             │
/// │  Wochenserie-Banner, Fortschritt-Ringe, Kalender mit      │
/// │  Tabs (Übungen/Schmerzen), Schmerzverlauf mit Diagramm.   │
/// └──────────────────────────────────────────────────────────┘
class ProgressScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenCalendar;
  const ProgressScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenCalendar,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _ringsInfoOpen = false;

  /// Rotiert durch 3 Nachrichten, wie im Prototyp (weeks % 3).
  String _weeklyStreakMessage(int weeks) {
    final w = weeks == 1 ? 'Woche' : 'Wochen';
    final messages = [
      'Super, du hältst dich schon $weeks $w in Folge an deine Ziele!',
      '$weeks $w am Stück – das ist echte Kontinuität. Weiter so!',
      'Beeindruckend: $weeks $w in Serie. Dein Körper dankt es dir.',
    ];
    return messages[weeks % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final rings = app.weeklyRings;
    final weeks = (app.streak / 7).floor().clamp(1, 999);

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        ScreenHeader(
          greeting: 'Dein Verlauf',
          initials: app.profile.initials,
          onAvatarTap: widget.onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Wochenserie-Banner (dunkel) ──
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.sageDeep,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.onDarkIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🔥', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WOCHENSERIE',
                              style: AppText.micro
                                  .copyWith(color: AppColors.onDarkSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            _weeklyStreakMessage(weeks),
                            style: AppText.caption.copyWith(
                                color: AppColors.white, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('$weeks',
                        style: AppText.screenTitle.copyWith(
                            color: AppColors.white, fontSize: 26)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Fortschritt dieser Woche (Ringe) ──
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DEIN FORTSCHRITT DIESER WOCHE',
                            style: AppText.micro),
                        GestureDetector(
                          onTap: () => setState(
                              () => _ringsInfoOpen = !_ringsInfoOpen),
                          child: Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.beige, width: 1.5),
                            ),
                            child: Text('i',
                                style: AppText.micro.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    if (_ringsInfoOpen) ...[
                      const SizedBox(height: AppSpacing.base),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.offwhite,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(color: AppColors.beige),
                        ),
                        child: Text(
                          'Jeder Ring steht für einen deiner Trainingspläne. '
                          'Je weiter ein Ring geschlossen ist, desto mehr '
                          'Einheiten hast du diese Woche absolviert. Ein '
                          'vollständiger Ring bedeutet: Wochenziel erreicht.',
                          style: AppText.caption.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.base),
                    rings.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg),
                            child: Center(
                              child: Text('Noch keine aktiven Pläne.',
                                  style: AppText.caption),
                            ),
                          )
                        : Row(
                            children: [
                              ConcentricRings(rings: rings, size: 150),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    for (final r in rings)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: r.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(r.label,
                                                  style: AppText.body
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600)),
                                            ),
                                            if (r.done >= r.goal)
                                              Icon(Icons.check,
                                                  size: 16, color: r.color)
                                            else
                                              Text('${r.done}/${r.goal}',
                                                  style: AppText.body
                                                      .copyWith(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    if (rings.isNotEmpty &&
                        rings.every((r) => r.done >= r.goal))
                      Container(
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.only(top: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: AppColors.beige)),
                        ),
                        child: Text(
                          'Alle Bereiche diese Woche erfüllt – stark! 🎉',
                          style: AppText.caption.copyWith(
                              color: AppColors.sageDeep,
                              fontWeight: FontWeight.w500,
                              height: 1.5),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Kalender mit Tabs ──
              const SectionTitle('Kalender'),
              _CalendarTabs(
                mode: app.calendarMode,
                onChange: app.setCalendarMode,
              ),
              const SizedBox(height: AppSpacing.md),
              CalendarWidget(
                onExpand: widget.onOpenCalendar,
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Schmerzverlauf ──
              const SectionTitle('Schmerzverlauf'),
              Text('Beobachte, wie sich deine Beschwerden über die Zeit entwickeln.',
                  style: AppText.caption.copyWith(height: 1.5)),
              const SizedBox(height: AppSpacing.base),
              const PainHistoryCarousel(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tab-Umschalter "Übungen / Schmerzen" über dem Kalender.
class _CalendarTabs extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChange;
  const _CalendarTabs({required this.mode, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.beige),
      ),
      child: Row(
        children: [
          _tab(context, 'exercises', 'Übungen'),
          _tab(context, 'pain', 'Schmerzen'),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String id, String label) {
    final active = mode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(id),
        child: AnimatedContainer(
          duration: AppMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.iconSmall),
          ),
          child: Text(label,
              style: AppText.body.copyWith(
                color: active ? AppColors.sageDeep : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              )),
        ),
      ),
    );
  }
}
