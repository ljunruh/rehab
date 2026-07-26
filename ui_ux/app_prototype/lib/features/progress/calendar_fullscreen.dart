import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/api_models.dart';
import 'package:app_prototype/data/provider/calender_provider.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import 'day_detail_sheet.dart';

/// PERSON 3 — Kalender im Vollbild.
///
/// Zeigt mehrere Monate untereinander (voriger, aktueller, +1, +2) mit
/// gefüllten Tages-Kreisen: im Schmerz-Modus als Farbverlauf je nach
/// Schmerzlevel (1–10), im Übungs-Modus in der Farbe der Trainings-
/// Region, plus Warn-Punkt bei starkem Schmerz an Trainingstagen.
/// Entspricht CalendarFullscreen im JSX-Prototyp.
class CalendarFullscreen extends StatelessWidget {
  final VoidCallback onBack;
  const CalendarFullscreen({super.key, required this.onBack});

  static const _painColors = {
    1: Color(0xFFF5E1D7),
    2: Color(0xFFEFCFC0),
    3: Color(0xFFE9C2B0),
    4: Color(0xFFE1AF9A),
    5: Color(0xFFD89A82),
    6: Color(0xFFCF876A),
    7: Color(0xFFC57658),
    8: Color(0xFFB96849),
    9: Color(0xFFA5573B),
    10: Color(0xFF8A4329),
  };

  static Color _painColorFor(int level) =>
      _painColors[level.clamp(1, 10)] ?? _painColors[1]!;

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final mode = calendarProvider.calendarMode;
    final now = DateTime.now();

    final months = [
      for (int offset = -1; offset <= 2; offset++)
        DateTime(now.year, now.month + offset, 1),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, AppSpacing.sm),
          child: Row(
            children: [
              AppBackButton(onTap: onBack),
              Expanded(
                child: Column(
                  children: [
                    Text('Kalender', style: AppText.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      '${_MonthGrid.monthNames[now.month - 1]} ${now.year}',
                      style: AppText.micro,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.beige),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 40),
            children: [
              for (final m in months) ...[
                _MonthGrid(
                  year: m.year,
                  month: m.month,
                  mode: mode,
                  isCurrent: m.year == now.year && m.month == now.month,
                  painColorFor: _painColorFor,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatefulWidget {
  final int year;
  final int month;
  final CalendarMode mode;
  final bool isCurrent;
  final Color Function(int) painColorFor;

  const _MonthGrid({
    required this.year,
    required this.month,
    required this.mode,
    required this.isCurrent,
    required this.painColorFor,
  });

  static const weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  Map<String, List<Plan>> _completedPlansByDate = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthData();
    });
  }

  @override
  void didUpdateWidget(covariant _MonthGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      _loadMonthData();
    }
  }

  /// Lädt alle absolvierten Pläne für die Tage dieses Monats im Hintergrund
  Future<void> _loadMonthData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final planLogProvider = context.read<PlanLogExerciseProvider>();
    final planProvider = context.read<PlanProvider>();

    final daysInMonth = DateUtils.getDaysInMonth(widget.year, widget.month);
    final Map<String, List<Plan>> tempMap = {};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(widget.year, widget.month, day);
      final key = _key(day);

      final completed = await planLogProvider.getCompletedPlansForDate(
        date,
        planProvider.plans,
      );

      if (completed.isNotEmpty) {
        tempMap[key] = completed;
      }
    }

    if (!mounted) return;
    setState(() {
      _completedPlansByDate = tempMap;
      _isLoading = false;
    });
  }

  String _key(int day) =>
      '${widget.year}-${widget.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final painProvider = context.watch<PainLogProvider>();

    final today = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(widget.year, widget.month);
    final firstWeekday = (DateTime(widget.year, widget.month, 1).weekday + 6) % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${_MonthGrid.monthNames[widget.month - 1]} ${widget.year}',
                style: AppText.screenTitle.copyWith(fontSize: 18)),
            if (widget.isCurrent) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Aktuell',
                    style: AppText.micro.copyWith(color: AppColors.sageDeep)),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final w in _MonthGrid.weekdays)
              Expanded(child: Center(child: Text(w, style: AppText.micro))),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.95,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox.shrink();
            final day = index - firstWeekday + 1;
            final key = _key(day);
            final date = DateTime(widget.year, widget.month, day);
            final isToday = today.year == widget.year &&
                today.month == widget.month &&
                today.day == day;

            final painToday = painProvider.getLogsForDateKey(key);
            final maxPain = painToday.isEmpty
                ? null
                : painToday.map((p) => p.level).reduce((a, b) => a > b ? a : b);
            final hasHighPain = maxPain != null && maxPain >= 7;

            // Synchroner Zugriff auf den im initState geladenen Cache!
            final completedPlans = _completedPlansByDate[key] ?? [];
            final hasCompletedExercises = completedPlans.isNotEmpty;

            Color? bg;
            Color textColor = AppColors.text;
            FontWeight weight = FontWeight.w400;

            if (widget.mode == CalendarMode.pain && maxPain != null) {
              bg = widget.painColorFor(maxPain);
              textColor = maxPain >= 5 ? AppColors.white : AppColors.text;
              weight = FontWeight.w600;
            } else if (widget.mode == CalendarMode.exercises && hasCompletedExercises) {
              bg = completedPlans.first.color;
              textColor = AppColors.white;
              weight = FontWeight.w600;
            }

            final showWarnDot = widget.mode == CalendarMode.exercises &&
                hasCompletedExercises &&
                hasHighPain;

            return GestureDetector(
              onTap: () => DayDetailSheet.show(context, date),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.transparent : bg,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppColors.sageDeep, width: 1.5)
                          : null,
                    ),
                    child: Text('$day',
                        style: AppText.caption.copyWith(
                          color: isToday ? AppColors.text : textColor,
                          fontWeight: isToday ? FontWeight.w600 : weight,
                        )),
                  ),
                  if (widget.mode == CalendarMode.pain && painToday.isNotEmpty)
                    Positioned(
                      bottom: 3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: painToday.take(3).map((log) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: log.region.color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (showWarnDot)
                    const Positioned(
                      top: 2,
                      right: 2,
                      child: _WarnDot(),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WarnDot extends StatelessWidget {
  const _WarnDot();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/other/lightningbolt.svg',
      width: 16,
      height: 16,
    );
  }
}