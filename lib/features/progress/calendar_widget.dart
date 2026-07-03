import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// Monatskalender mit farbigen Tagespunkten.
/// Tage mit Übungen bekommen einen Punkt in der Plan-Farbe, Tage mit hohem
/// Schmerz einen Warn-Ring. Antippen öffnet das Tagesdetail.
class CalendarWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDayTap;
  const CalendarWidget({super.key, required this.onDayTap});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late int _year;
  late int _month;
  bool _legendOpen = false;

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _prev() => setState(() {
        if (_month == 1) {
          _month = 12;
          _year--;
        } else {
          _month--;
        }
      });

  void _next() => setState(() {
        if (_month == 12) {
          _month = 1;
          _year++;
        } else {
          _month++;
        }
      });

  String _key(int day) =>
      '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final today = DateTime.now();
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstWeekday = (DateTime(_year, _month, 1).weekday + 6) % 7;

    return AppCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBtn(icon: Icons.chevron_left, onTap: _prev),
                  Row(
                    children: [
                      Text('${_months[_month - 1]} $_year',
                          style: AppText.cardTitle),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _legendOpen = !_legendOpen),
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _legendOpen
                                ? AppColors.sageLight
                                : AppColors.offwhite,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline,
                              size: 11, color: AppColors.sageDeep),
                        ),
                      ),
                    ],
                  ),
                  _NavBtn(icon: Icons.chevron_right, onTap: _next),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  for (final w in _weekdays)
                    Expanded(
                        child: Center(
                            child: Text(w, style: AppText.micro))),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: firstWeekday + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) return const SizedBox.shrink();
                  final day = index - firstWeekday + 1;
                  final key = _key(day);
                  final isToday = today.year == _year &&
                      today.month == _month &&
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
                    onTap: () => widget.onDayTap(DateTime(_year, _month, day)),
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
                                ? Border.all(
                                    color: AppColors.alertSoft, width: 2)
                                : null,
                          ),
                          child: Text('$day',
                              style: AppText.caption.copyWith(
                                color: isToday
                                    ? AppColors.sageDeep
                                    : AppColors.text,
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (dotColor != null) _Dot(dotColor),
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
          if (_legendOpen)
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              child: Center(child: _LegendPopover(app: app)),
            ),
        ],
      ),
    );
  }
}

class _LegendPopover extends StatelessWidget {
  final UiState app;
  const _LegendPopover({required this.app});

  @override
  Widget build(BuildContext context) {
    final regions = app.activePlans.map((p) => p.region).toSet().toList();
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.beige),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Legende',
              style: AppText.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Text('Farbe = Trainingsbereich des Tages', style: AppText.micro),
          const SizedBox(height: AppSpacing.sm),
          for (final r in regions)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: app.colorForRegion(r),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(r, style: AppText.micro),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.alertSoft,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child:
                        Text('Termin / hoher Schmerzwert', style: AppText.micro)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.offwhite,
          borderRadius: BorderRadius.circular(AppRadius.iconSmall),
        ),
        child: Icon(icon, size: 16, color: AppColors.sageDeep),
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
