import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../navigation/screen_header.dart';

/// PERSON 3 — KALENDER (Teil 2 des Fortschritt-Bereichs).
///
/// Grundgerüst des Kalenders. Hier später: Monatsraster mit farbigen
/// Plan-Punkten, Vollbild-Modus und Tagesdetail-Sheet (siehe JSX-Prototyp
/// CalendarWidget / CalendarFullscreen / DayDetailSheet).
class CalendarScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;
  const CalendarScreen({super.key, required this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;

    // Ereignisse nach Datum gruppieren (vereinfachte Liste).
    final byDate = <String, List<CalendarEvent>>{};
    for (final e in app.calendarEvents) {
      byDate.putIfAbsent(e.dateKey, () => []).add(e);
    }
    final sortedKeys = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
      children: [
        ScreenHeader(
          greeting: 'Kalender',
          subtitle: 'Deine Übungen & Termine',
          initials: profile.initials,
          onAvatarTap: onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final key in sortedKeys) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
                  child: Text(key, style: AppText.micro),
                ),
                ...byDate[key]!.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _EventRow(event: e),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final CalendarEvent event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final isAppointment = event.type == 'appointment';
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: isAppointment ? AppColors.alertSoft : AppColors.sage,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppText.cardTitle),
                Text('${event.time} Uhr', style: AppText.caption),
              ],
            ),
          ),
          if (event.done)
            const Icon(Icons.check_circle, color: AppColors.sage, size: 20),
        ],
      ),
    );
  }
}
