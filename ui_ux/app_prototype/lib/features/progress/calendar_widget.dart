import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// Kompakter Monatskalender (Clue-Style gefüllte Tageskreise).
///
/// Im Schmerz-Modus: Farbfläche je nach Schmerzlevel (1–10, hell→dunkel).
/// Im Übungs-Modus: Farbfläche in der Region-Farbe des trainierten
/// Bereichs. Unten eine Legenden-Zeile (je nach Modus) + "Öffnen"-Link.
/// Tippen (fast überall) öffnet den Vollbild-Kalender.
/// Entspricht CalendarWidget im JSX-Prototyp.
class CalendarWidget extends StatefulWidget {
  final VoidCallback onExpand;
  const CalendarWidget({super.key, required this.onExpand});

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
    final painProvider = context.watch<PainLogProvider>();
    final mode = app.calendarMode; // "exercises" | "pain"
    final today = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(_year, _month);
    final firstWeekday = (DateTime(_year, _month, 1).weekday + 6) % 7;

    // Regionen für die Legende ermitteln (ohne BodyPart.none)
    final monthLogs = painProvider.getLogsForMonth(_year, _month);
    final activePainRegions = monthLogs
        .map((l) => l.region)
        .where((r) => r != BodyPart.none)
        .toSet()
        .toList();

    return GestureDetector(
      onTap: widget.onExpand,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
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
                        Text('${_months[_month - 1]} $_year', style: AppText.cardTitle),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _legendOpen = !_legendOpen),
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _legendOpen ? AppColors.sageLight : AppColors.offwhite,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/other/info-green.svg',
                              width: 11,
                              height: 11,
                            ),
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
                    final isToday = today.year == _year && today.month == _month && today.day == day;

                    final events = app.eventsOn(key);
                    final doneExercises = events.where((e) => e.type == 'exercise' && e.done).toList();

                    final painLogs = painProvider.getLogsForDateKey(key);
                    final maxPain = painLogs.isEmpty
                        ? null
                        : painLogs.map((p) => p.level).reduce((a, b) => a > b ? a : b);

                    Color? bg;
                    Color textColor = AppColors.text;
                    FontWeight weight = FontWeight.w400;

                    if (mode == 'pain' && maxPain != null) {
                      bg = _painColorFor(maxPain);
                      textColor = maxPain >= 5 ? AppColors.white : AppColors.text;
                      weight = FontWeight.w600;
                    } else if (mode == 'exercises' && doneExercises.isNotEmpty) {
                      bg = app.colorForRegion(doneExercises.first.region);
                      textColor = AppColors.white;
                      weight = FontWeight.w600;
                    }

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isToday ? Colors.transparent : bg,
                            shape: BoxShape.circle,
                            border: isToday ? Border.all(color: AppColors.sageDeep, width: 1.5) : null,
                          ),
                          child: Text('$day',
                              style: AppText.caption.copyWith(
                                color: isToday ? AppColors.text : textColor,
                                fontWeight: isToday ? FontWeight.w600 : weight,
                              )),
                        ),
                        // Kleine farbige Punkte für Schmerzregionen
                        if (mode == 'pain' && painLogs.isNotEmpty)
                          Positioned(
                            bottom: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: painLogs.take(3).map((log) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: app.colorForRegion(log.region.label),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.beige)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: mode == 'pain'
                            ? Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: activePainRegions.take(3).map((r) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: app.colorForRegion(r.label),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Nutze HIER .label anstelle von .name:
                                Text(r.label, style: AppText.micro),
                              ],
                            );
                          }).toList(),
                        )
                            : Container(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Öffnen',
                              style: AppText.micro.copyWith(
                                  color: AppColors.sageDeep, fontWeight: FontWeight.w500)),
                          const Icon(Icons.chevron_right, size: 13, color: AppColors.sageDeep),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_legendOpen)
              Positioned(
                top: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: _LegendPopover(
                    app: app,
                    mode: mode,
                    activePainRegions: activePainRegions,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendPopover extends StatelessWidget {
  final UiState app;
  final String mode;
  final List<BodyPart> activePainRegions;

  const _LegendPopover({
    required this.app,
    required this.mode,
    required this.activePainRegions,
  });

  @override
  Widget build(BuildContext context) {
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
          Text('Legende', style: AppText.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          if (mode == 'pain') ...[
            Text('Körperregionen im Monat:', style: AppText.micro),
            const SizedBox(height: AppSpacing.sm),
            if (activePainRegions.isEmpty)
              Text('Keine Eintrags-Daten', style: AppText.micro)
            else
              for (final r in activePainRegions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: app.colorForRegion(r.label),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Auch hier r.label für sauberes Deutsch:
                      Text(r.label, style: AppText.micro),
                    ],
                  ),
                ),
          ],
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
