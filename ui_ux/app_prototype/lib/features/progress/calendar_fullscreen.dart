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
/// Zeigt alle 12 Monate eines ausgewählten Jahres untereinander an mit
/// gefüllten Tages-Kreisen: im Schmerz-Modus als Farbverlauf je nach
/// Schmerzlevel (1–10), im Übungs-Modus in der Farbe der Trainings-
/// Region, plus Warn-Punkt bei starkem Schmerz an Trainingstagen.
/// Entspricht CalendarFullscreen im JSX-Prototyp.
class CalendarFullscreen extends StatefulWidget {
  final VoidCallback onBack;
  final DateTime initialDate;

  const CalendarFullscreen({
    super.key,
    required this.onBack,
    required this.initialDate,
  });

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
  State<CalendarFullscreen> createState() => _CalendarFullscreenState();
}

class _CalendarFullscreenState extends State<CalendarFullscreen> {
  late int _selectedYear;
  late final ScrollController _scrollController;
  late final List<GlobalKey> _monthKeys;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _scrollController = ScrollController();
    _monthKeys = List.generate(12, (_) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToMonth(widget.initialDate.month);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToMonth(int month, {bool animate = false}) {
    final targetIndex = (month - 1).clamp(0, 11);
    final targetKey = _monthKeys[targetIndex];
    final context = targetKey.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: animate ? AppMotion.standard : Duration.zero,
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    } else if (_scrollController.hasClients) {
      final offset = targetIndex * 290.0;
      if (animate) {
        _scrollController.animateTo(
          offset,
          duration: AppMotion.standard,
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    }
  }

  void _changeYear(int year) {
    if (year < 2020 || year > 2035) return;
    setState(() {
      _selectedYear = year;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      if (year == now.year) {
        _scrollToMonth(now.month, animate: true);
      } else {
        _scrollToMonth(1, animate: true);
      }
    });
  }

  Future<void> _showYearPickerModal() async {
    final now = DateTime.now();
    final pickedYear = await showDialog<int>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cream,
        elevation: 8,
        shadowColor: AppColors.toastShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jahr auswählen',
                      style: AppText.cardTitle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.offwhite,
                          borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                        ),
                        child: const Icon(Icons.close, size: 14, color: AppColors.text),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: (now.year + 2) - 2020 + 1,
                    itemBuilder: (context, index) {
                      final year = 2020 + index;
                      final isSelected = year == _selectedYear;
                      return GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(year),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.sageDeep : AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            border: Border.all(
                              color: isSelected ? AppColors.sageDeep : AppColors.beige,
                            ),
                          ),
                          child: Text(
                            '$year',
                            style: AppText.caption.copyWith(
                              color: isSelected ? Colors.white : AppColors.text,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (pickedYear != null && pickedYear != _selectedYear) {
      _changeYear(pickedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final mode = calendarProvider.calendarMode;
    final now = DateTime.now();

    final canPrevYear = _selectedYear > 2020;
    final canNextYear = _selectedYear < (now.year + 2);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, AppSpacing.sm),
          child: Row(
            children: [
              AppBackButton(onTap: widget.onBack),
              Expanded(
                child: Column(
                  children: [
                    Text('Kalender', style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: canPrevYear ? () => _changeYear(_selectedYear - 1) : null,
                          child: Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: canPrevYear ? AppColors.offwhite : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              size: 18,
                              color: canPrevYear ? AppColors.sageDeep : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _showYearPickerModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sageLight,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_selectedYear',
                                  style: AppText.caption.copyWith(
                                    color: AppColors.sageDeep,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: AppColors.sageDeep,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: canNextYear ? () => _changeYear(_selectedYear + 1) : null,
                          child: Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: canNextYear ? AppColors.offwhite : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: canNextYear ? AppColors.sageDeep : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
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
          child: ListView.builder(
            controller: _scrollController,
            cacheExtent: 10000.0,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 40),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isCurrent = _selectedYear == now.year && month == now.month;

              return Container(
                key: _monthKeys[index],
                margin: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
                child: _MonthGrid(
                  year: _selectedYear,
                  month: month,
                  mode: mode,
                  isCurrent: isCurrent,
                  painColorFor: CalendarFullscreen._painColorFor,
                ),
              );
            },
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