import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
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
    final painProvider = context.watch<PainLogProvider>();
    final planLogProvider = context.watch<PlanLogExerciseProvider>();
    final allPlans = context.watch<PlanProvider>().plans;
    final profile = app.profile;

    final Map<String, List<dynamic>> byDate = {};

    for (final e in app.calendarEvents) {
      byDate.putIfAbsent(e.dateKey, () => []).add(e);
    }

    for (final pain in painProvider.allPainLogs) {
      byDate.putIfAbsent(pain.dateKey, () => []).add(pain);
    }

    final sortedKeys = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
      children: [
        ScreenHeader(
          greeting: 'Kalender',
          subtitle: 'Deine Übungen & Schmerzeinträge',
          initials: profile.initials,
          onAvatarTap: onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sortedKeys.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: Text('Keine Einträge vorhanden.')),
                )
              else
                for (final key in sortedKeys) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
                    child: Text(key, style: AppText.micro),
                  ),
                  ...byDate[key]!.map((item) {
                    if (item is CalendarEvent) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _EventRow(event: item),
                      );
                    } else {
                      final pain = item;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _PainRow(
                          regionLabel: pain.region.label,
                          level: pain.level,
                          note: pain.note,
                          color: pain.region.color,
                        ),
                      );
                    }
                  }),
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

class _PainRow extends StatelessWidget {
  final String regionLabel;
  final int level;
  final String note;
  final Color color;

  const _PainRow({
    required this.regionLabel,
    required this.level,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$regionLabel: Level $level/10', style: AppText.cardTitle),
                Text(
                  note.isNotEmpty ? note : 'Keine Notiz',
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
