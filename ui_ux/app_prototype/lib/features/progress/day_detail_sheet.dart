import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// Tagesdetail-Sheet: zeigt Übungen, Termine und Schmerz-Einträge eines Tages.
class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  const DayDetailSheet({super.key, required this.date});

  static const _weekdays = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
    'Freitag', 'Samstag', 'Sonntag'
  ];
  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  static Future<void> show(BuildContext context, DateTime date) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => DayDetailSheet(date: date),
    );
  }

  String get _dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final painProvider = context.watch<PainLogProvider>();
    final planLogProvider = context.watch<PlanLogExerciseProvider>();
    final allPlans = context.watch<PlanProvider>().plans;

    final events = app.eventsOn(_dateKey);
    final appointments = events.where((e) => e.type == 'appointment').toList();

    // Echte Schmerzeinträge aus dem PainLogProvider (Isar DB)
    final pains = painProvider.getLogsForDateKey(_dateKey);
    final weekday = _weekdays[(date.weekday - 1) % 7];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
      child: FutureBuilder<List<Plan>>(
        future: planLogProvider.getCompletedPlansForDate(date, allPlans),
        builder: (context, snapshot) {
          final completedPlans = snapshot.data ?? [];

          return Column(
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
              Text('$weekday, ${date.day}. ${_months[date.month - 1]}',
                  style: AppText.screenTitle.copyWith(fontSize: 20)),
              const SizedBox(height: AppSpacing.lg),
              if (completedPlans.isEmpty && appointments.isEmpty && pains.isEmpty)
                _Empty()
              else ...[
                if (completedPlans.isNotEmpty) ...[
                  Text('ABGESCHLOSSENE PLÄNE', style: AppText.micro),
                  const SizedBox(height: AppSpacing.sm),
                  ...completedPlans.map((plan) => _Row(
                    color: app.colorForRegion(plan.region.name),
                    title: plan.name,
                    subtitle: '${plan.exercises.length} Übungen absolviert',
                    done: true,
                  )),
                  const SizedBox(height: AppSpacing.base),
                ],
                if (appointments.isNotEmpty) ...[
                  Text('TERMINE', style: AppText.micro),
                  const SizedBox(height: AppSpacing.sm),
                  ...appointments.map((a) => _Row(
                    color: AppColors.alertSoft,
                    title: a.title,
                    subtitle: '${a.time} Uhr${(a.note != null && a.note!.isNotEmpty) ? ' · ${a.note}' : ''}',
                  )),
                  const SizedBox(height: AppSpacing.base),
                ],
                if (pains.isNotEmpty) ...[
                  Text('SCHMERZ-EINTRÄGE', style: AppText.micro),
                  const SizedBox(height: AppSpacing.sm),
                  ...pains.map((p) => _Row(
                    color: app.colorForRegion(p.region.name),
                    title: '${p.region.label}: Level ${p.level}/10',
                    subtitle: p.note.isNotEmpty ? p.note : 'Keine Notiz',
                  )),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final bool done;

  const _Row({
    required this.color,
    required this.title,
    required this.subtitle,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 36,
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
                  Text(title, style: AppText.cardTitle),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            if (done)
              const Icon(Icons.check_circle, size: 18, color: AppColors.sage),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      alignment: Alignment.center,
      child: Text('An diesem Tag ist nichts eingetragen.',
          style: AppText.caption),
    );
  }
}
