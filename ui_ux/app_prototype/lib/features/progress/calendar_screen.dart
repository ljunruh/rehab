/// PERSON 3 — KALENDER (Teil 2 des Fortschritt-Bereichs).
///
/// Grundgerüst des Kalenders. Hier später: Monatsraster mit farbigen
/// Plan-Punkten, Vollbild-Modus und Tagesdetail-Sheet (siehe JSX-Prototyp
/// CalendarWidget / CalendarFullscreen / DayDetailSheet).
import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../navigation/screen_header.dart';

/// Person 3 — Kalender / Verlauf.
///
/// Zeitstrahl-Ansicht aller vergangenen Schmerzeinträge und absolvierten Pläne.
/// Lädt asynchrone Log-Daten im [initState] vor, um die Liste komplett synchron zu rendern.
class CalendarScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  const CalendarScreen({super.key, required this.onOpenProfile});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isLoading = false;

  /// Speichert fertig aufbereitete Einträge pro Datumstag.
  /// Key: DateKey ("YYYY-MM-DD") -> Value: Liste von Objekten (PainLog, Plan, etc.)
  Map<String, List<dynamic>> _groupedEntries = {};

  @override
  void initState() {
    super.initState();
    // Einmalig nach dem ersten Frame die Daten aus den Providern zusammenführen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  /// Führt Schmerzeinträge und absolvierte Pläne synchron zusammen.
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final painProvider = context.read<PainLogProvider>();
    final planLogProvider = context.read<PlanLogExerciseProvider>();
    final planProvider = context.read<PlanProvider>();

    final Map<String, List<dynamic>> byDate = {};

    // 1. Schmerzeinträge aus dem PainLogProvider
    for (final pain in painProvider.allPainLogs) {
      byDate.putIfAbsent(pain.dateKey, () => []).add(pain);
    }

    // 2. Absolvierte Pläne für vorhandene Daten ermitteln
    // Wir ermitteln alle einzigartigen Tage aus den geladenen Plan-Logs
    final allLogs = planLogProvider.allLogs;
    final uniqueDates = allLogs.map((log) => DateTime(
      log.timestamp.year,
      log.timestamp.month,
      log.timestamp.day,
    )).toSet();

    for (final date in uniqueDates) {
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final completedPlans = await planLogProvider.getCompletedPlansForDate(
        date,
        planProvider.plans,
      );

      for (final plan in completedPlans) {
        byDate.putIfAbsent(key, () => []).add(plan);
      }
    }

    if (!mounted) return;
    setState(() {
      _groupedEntries = byDate;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // Profil-Initialen ermitteln
    final String initials = (user != null && user.name.isNotEmpty)
        ? user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    final sortedKeys = _groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
      children: [
        ScreenHeader(
          greeting: 'Kalender',
          subtitle: 'Deine Übungen & Schmerzeinträge',
          initials: initials,
          onAvatarTap: widget.onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (sortedKeys.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: Text('Keine Einträge vorhanden.')),
                )
              else
                for (final key in sortedKeys) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.md),
                    child: Text(key, style: AppText.micro.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  ..._groupedEntries[key]!.map((item) {
                    if (item is Plan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CompletedPlanRow(plan: item),
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

/// Zeile für einen absolvierten Trainingsplan
class _CompletedPlanRow extends StatelessWidget {
  final Plan plan;
  const _CompletedPlanRow({required this.plan});

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
              color: plan.color,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: AppText.cardTitle),
                Text(
                  '${plan.exercises.length} Übungen abgeschlossen',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.sageDeep, size: 20),
        ],
      ),
    );
  }
}

/// Zeile für einen Schmerzeintrag
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
