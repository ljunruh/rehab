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
  bool _isLoading = false;

  /// Cache für die abgeschlossenen Pläne pro Tag im aktuellen Monat.
  /// Key: "YYYY-MM-DD", Value: Liste absolvierter Pläne an diesem Tag.
  Map<String, List<Plan>> _completedPlansByDate = {};

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

    // Einmalig beim Erstellen des Widgets laden:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthData();
    });
  }

  /// Lädt alle Übungs-Logs für jeden Tag des aktuellen Monats im Hintergrund
  Future<void> _loadMonthData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final planLogProvider = context.read<PlanLogExerciseProvider>();
    final planProvider = context.read<PlanProvider>();

    final daysInMonth = DateUtils.getDaysInMonth(_year, _month);
    final Map<String, List<Plan>> tempMap = {};

    // Schleife über alle Tage des aktiven Monats
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_year, _month, day);
      final key = _key(day);

      final completed = await planLogProvider.getCompletedPlansForDate(date, planProvider.plans);

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

  void _prev() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
    _loadMonthData(); // Daten für den neuen Monat laden
  }

  void _next() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
    _loadMonthData(); // Daten für den neuen Monat laden
  }

  String _key(int day) =>
      '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Hilfs-Widget für die kleine Schmerz-Farbleiste (1 bis 10) unten im Schmerz-Modus
  Widget _buildPainScaleLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('1', style: AppText.micro),
        const SizedBox(width: 4),
        Row(
          children: List.generate(10, (index) {
            final level = index + 1;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _painColorFor(level),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(width: 4),
        Text('10', style: AppText.micro),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final painProvider = context.watch<PainLogProvider>();

    final mode = calendarProvider.calendarMode;
    final today = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(_year, _month);
    final firstWeekday = (DateTime(_year, _month, 1).weekday + 6) % 7;

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

                    // 1. Schmerzen (synchron aus Provider)
                    final painLogs = painProvider.getLogsForDateKey(key);
                    final maxPain = painLogs.isEmpty
                        ? null
                        : painLogs.map((p) => p.level).reduce((a, b) => a > b ? a : b);

                    // 2. Abgeschlossene Übungen (synchron aus unserem geladenen State)
                    final completedPlans = _completedPlansByDate[key] ?? [];

                    Color? bg;
                    Color textColor = AppColors.text;
                    FontWeight weight = FontWeight.w400;

                    if (mode == CalendarMode.pain && maxPain != null) {
                      bg = _painColorFor(maxPain);
                      textColor = maxPain >= 5 ? AppColors.white : AppColors.text;
                      weight = FontWeight.w600;
                    } else if (mode == CalendarMode.exercises && completedPlans.isNotEmpty) {
                      bg = completedPlans.first.color;
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
                        if (mode == CalendarMode.pain && painLogs.isNotEmpty)
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
                                    color: log.region.color,
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
                        child: mode == CalendarMode.exercises
                            ? Builder(
                          builder: (context) {
                            // 1. Alle absolvierten Pläne dieses Monats ermitteln
                            final monthPrefix = '$_year-${_month.toString().padLeft(2, '0')}';
                            final monthEntries = _completedPlansByDate.entries
                                .where((entry) => entry.key.startsWith(monthPrefix));

                            final List<Plan> completedPlansInMonth = [];
                            for (var entry in monthEntries) {
                              completedPlansInMonth.addAll(entry.value);
                            }

                            // 2. Eindeutige Körperregionen (BodyParts) des Monats filtern
                            final trainedRegionsInMonth = completedPlansInMonth
                                .map((p) => p.region)
                                .where((r) => r != BodyPart.none)
                                .toSet()
                                .toList();

                            if (trainedRegionsInMonth.isEmpty) {
                              return Text(
                                'Keine Trainings',
                                style: AppText.micro.copyWith(color: AppColors.textMuted),
                              );
                            }

                            // 3. Maximal 3 trainierte Regionen unten mit kleiner Farbmarkierung anzeigen
                            return Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: trainedRegionsInMonth.take(3).map((r) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: r.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(r.label, style: AppText.micro),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        )
                        // Im Schmerz-Modus wird die farbige Schmerzskala (1 bis 10) angezeigt
                            : _buildPainScaleLegend(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Öffnen',
                            style: AppText.micro.copyWith(
                              color: AppColors.sageDeep,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                    mode: mode,
                    activePainRegions: activePainRegions,
                    year: _year,
                    month: _month,
                    completedPlansByDate: _completedPlansByDate,
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
  final CalendarMode mode;
  final List<BodyPart> activePainRegions;
  final int year;
  final int month;
  final Map<String, List<Plan>> completedPlansByDate;

  const _LegendPopover({
    super.key,
    required this.mode,
    required this.activePainRegions,
    required this.year,
    required this.month,
    required this.completedPlansByDate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Alle absolvierten Pläne des ausgewählten Monats ermitteln
    final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';

    final completedPlansInMonth = completedPlansByDate.entries
        .where((entry) => entry.key.startsWith(monthPrefix))
        .expand((entry) => entry.value);

    // 2. Nur die eindeutigen Trainingsbereiche (BodyParts) filtern, die in diesem Monat trainiert wurden
    final trainedRegionsInMonth = completedPlansInMonth
        .map((plan) => plan.region)
        .where((region) => region != BodyPart.none)
        .toSet()
        .toList();

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
          Text(
            'Legende',
            style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (mode == CalendarMode.exercises) ...[
            Text('Trainingsbereiche des Monats', style: AppText.micro),
            const SizedBox(height: AppSpacing.sm),

            // Wenn in diesem Monat noch kein Training absolviert wurde:
            if (trainedRegionsInMonth.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Keine Trainings in diesem Monat',
                  style: AppText.micro.copyWith(color: AppColors.textMuted),
                ),
              )
            else
            // Anzeige der tatsächlich trainierten Bereiche
              for (final region in trainedRegionsInMonth)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: region.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          region.label,
                          style: AppText.micro,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.sageDeep, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Heutiger Tag', style: AppText.micro),
                ],
              ),
            ),
          ] else ...[
            Text('Farbe = Schmerzlevel (1–10)', style: AppText.micro),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Je dunkler der Kreis, desto höher das Schmerzlevel an diesem Tag.',
              style: AppText.micro.copyWith(color: AppColors.textMuted),
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
