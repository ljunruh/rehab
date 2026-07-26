import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/data/repository/plan_log_exercise_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Tagesdetail-Sheet: zeigt Übungen, Termine und Schmerz-Einträge eines Tages.
class DayDetailSheet extends StatefulWidget {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => DayDetailSheet(date: date),
    );
  }

  @override
  State<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<DayDetailSheet> {
  List<PlanDayProgress> _planProgresses = [];
  bool _isLoading = true;

  String get _dateKey =>
      '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlanProgresses();
    });
  }

  /// Lädt alle gestarteten Pläne für den Tag über den Provider
  Future<void> _loadPlanProgresses() async {
    if (!mounted) return;

    final planLogProvider = context.read<PlanLogExerciseProvider>();
    final allPlans = context.read<PlanProvider>().plans;

    final progresses = await planLogProvider.getPlanProgressForDate(widget.date, allPlans);

    if (!mounted) return;
    setState(() {
      _planProgresses = progresses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final painProvider = context.watch<PainLogProvider>();

    // Schmerzeinträge für das gewählte Datum laden
    final pains = painProvider.getLogsForDateKey(_dateKey);
    final weekday = DayDetailSheet._weekdays[(widget.date.weekday - 1) % 7];

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
          Text('$weekday, ${widget.date.day}. ${DayDetailSheet._months[widget.date.month - 1]}',
              style: AppText.screenTitle.copyWith(fontSize: 20)),
          const SizedBox(height: AppSpacing.lg),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_planProgresses.isEmpty && pains.isEmpty)
            _Empty()
          else ...[
              if (_planProgresses.isNotEmpty) ...[
                Text('TRAININGSEINHEITEN', style: AppText.micro),
                const SizedBox(height: AppSpacing.sm),
                ..._planProgresses.map((progress) => _Row(
                  color: progress.plan.color,
                  title: progress.plan.name,
                  subtitle: '${progress.completedExercisesCount} von ${progress.totalExercisesCount} Übungen absolviert',
                  done: progress.isFullyCompleted, // Grüne Häkchen nur bei 100%
                )),
                const SizedBox(height: AppSpacing.base),
              ],
              if (pains.isNotEmpty) ...[
                Text('SCHMERZ-EINTRÄGE', style: AppText.micro),
                const SizedBox(height: AppSpacing.sm),
                ...pains.map((p) => _Row(
                  color: p.region.color,
                  title: '${p.region.label}: Level ${p.level}/10',
                  subtitle: p.note.isNotEmpty ? p.note : 'Keine Notiz',
                )),
              ],
            ],
        ],
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
              const Icon(Icons.check_circle, size: 18, color: AppColors.sageDeep),
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
