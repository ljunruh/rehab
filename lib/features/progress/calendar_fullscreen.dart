import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import 'day_detail_sheet.dart';

/// PERSON 3 — Kalender im Vollbild.
///
/// Zeigt mehrere Monate untereinander (voriger, aktueller, nächste zwei) mit
/// farbigen Tagespunkten. Antippen eines Tages öffnet das Tagesdetail.
/// Entspricht CalendarFullscreen im JSX-Prototyp.
class CalendarFullscreen extends StatelessWidget {
  final VoidCallback onBack;
  const CalendarFullscreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Monate: voriger, aktueller, +1, +2
    final months = [
      for (int offset = -1; offset <= 2; offset++)
        DateTime(now.year, now.month + offset, 1),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBackButton(onTap: onBack),
            Text('Kalender', style: AppText.cardTitle),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final m in months) ...[
          _MonthGrid(year: m.year, month: m.month),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final int year;
  final int month;
  const _MonthGrid({required this.year, required this.month});

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  String _key(int day) =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final today = DateTime.now();
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = (DateTime(year, month, 1).weekday + 6) % 7;

    return AppCard(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${_months[month - 1]} $year',
                style: AppText.cardTitle),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(child: Center(child: Text(w, style: AppText.micro))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final key = _key(day);
              final isToday = today.year == year &&
                  today.month == month &&
                  today.day == day;
              final events = app.eventsOn(key);
              final exercises =
                  events.where((e) => e.type == 'exercise').toList();
              final hasHighPain = app.highPainDays.contains(key);
              final hasAppointment =
                  events.any((e) => e.type == 'appointment');
              Color? dotColor;
              if (exercises.isNotEmpty) {
                dotColor = app.colorForRegion(exercises.first.region);
              }

              return GestureDetector(
                onTap: () =>
                    DayDetailSheet.show(context, DateTime(year, month, day)),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.sageLight : null,
                        shape: BoxShape.circle,
                        border: hasHighPain
                            ? Border.all(color: AppColors.alertSoft, width: 2)
                            : null,
                      ),
                      child: Text('$day',
                          style: AppText.caption.copyWith(
                            color:
                                isToday ? AppColors.sageDeep : AppColors.text,
                            fontWeight:
                                isToday ? FontWeight.w600 : FontWeight.w400,
                          )),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (dotColor != null)
                            _Dot(dotColor),
                          if (hasAppointment) _Dot(AppColors.alertSoft),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
