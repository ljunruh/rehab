import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import 'pain_trend_chart.dart';

/// Schmerz-Verlauf-Karussell (wischbar über Körperregionen).
/// Pro Region: Titel, Ø-Badge, funktionierende Monats-Navigation
/// (kann nicht in die Zukunft), Liniendiagramm oder Leer-Hinweis für
/// den gewählten Monat, und ein Trend-Hinweis (4 Zustände).
/// Entspricht PainHistoryCarousel im JSX-Prototyp.
class PainHistoryCarousel extends StatefulWidget {
  const PainHistoryCarousel({super.key});

  @override
  State<PainHistoryCarousel> createState() => _PainHistoryCarouselState();
}

class _PainHistoryCarouselState extends State<PainHistoryCarousel> {
  final _controller = PageController(viewportFraction: 0.96);
  int _index = 0;

  // Offset pro Region (0 = aktueller Monat, -1 = Vormonat, …)
  final Map<BodyPart, int> _monthOffsets = {};

  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadActiveTrainedRegions();
      context.read<PainLogProvider>().loadLogs();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({int year, int month, String label}) _monthInfo(int offset) {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month + offset, 1);
    return (year: d.year, month: d.month, label: '${_months[d.month - 1]} ${d.year}');
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final painLogProvider = context.watch<PainLogProvider>();

    // Aktive Regionen aus den Plänen
    final regions = planProvider.activeRegions;

    if (regions.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
            child: Text(
              'Noch keine aktiven Trainings-Regionen vorhanden.',
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Der Trend-Hinweis erscheint erst ab zwei Einträgen. Ohne ihn braucht die
    // Karte spürbar weniger Platz – mit fester Höhe bliebe darunter eine große
    // leere Fläche stehen. Alle Seiten des Karussells brauchen dieselbe Höhe,
    // deshalb entscheidet hier, ob überhaupt eine Region einen Trend zeigt.
    final zeigtTrend = regions.any((region) {
      final info = _monthInfo(_monthOffsets[region] ?? 0);
      final entries = painLogProvider.getLogsForRegionAndMonth(
        region,
        info.year,
        info.month,
      );
      return painLogProvider.computeTrend(entries) != null;
    });

    return Column(
      children: [
        SizedBox(
          height: zeigtTrend ? 388 : 296,
          child: PageView.builder(
            controller: _controller,
            itemCount: regions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final region = regions[i];
              final offset = _monthOffsets[region] ?? 0;
              final info = _monthInfo(offset);

              // ── Logik an den Provider ausgelagert ──
              final entries = painLogProvider.getLogsForRegionAndMonth(
                region,
                info.year,
                info.month,
              );
              final trend = painLogProvider.computeTrend(entries);

              final avg = entries.isEmpty
                  ? null
                  : entries.map((e) => e.level).reduce((a, b) => a + b) /
                  entries.length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AppCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header mit Region & Durchschnitt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  region.label,
                                  style: AppText.screenTitle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'SCHMERZLEVEL-SKALA 1–10',
                                  style: AppText.micro,
                                ),
                              ],
                            ),
                            if (avg != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.sageLight,
                                  borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  'Ø ${avg.toStringAsFixed(1)}',
                                  style: AppText.cardTitle.copyWith(
                                    color: AppColors.sageDeep,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // Monatsnavigation
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.offwhite,
                            borderRadius:
                            BorderRadius.circular(AppRadius.input),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(
                                      () => _monthOffsets[region] = offset - 1,
                                ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.chevron_left,
                                    size: 16,
                                    color: AppColors.sageDeep,
                                  ),
                                ),
                              ),
                              Text(info.label, style: AppText.cardTitle),
                              GestureDetector(
                                onTap: offset >= 0
                                    ? null
                                    : () => setState(
                                      () => _monthOffsets[region] =
                                      offset + 1,
                                ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: offset >= 0
                                        ? AppColors.textMuted.withOpacity(0.45)
                                        : AppColors.sageDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // Graph oder Leer-Hinweis
                        if (entries.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.offwhite,
                              borderRadius:
                              BorderRadius.circular(AppRadius.card),
                            ),
                            child: Text(
                              'Für diesen Monat gibt es noch keine Einträge.',
                              textAlign: TextAlign.center,
                              style: AppText.caption.copyWith(height: 1.5),
                            ),
                          )
                        else
                          PainTrendChart(entries: entries, height: 110),

                        // Trend-Banner (wird nur angezeigt, wenn ein Trend vorhanden ist)
                        if (trend != null) ...[
                          const SizedBox(height: AppSpacing.base),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: trend.bg,
                              borderRadius:
                              BorderRadius.circular(AppRadius.input),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 2, right: 10),
                                  decoration: BoxDecoration(
                                    color: trend.fg,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    trend.text,
                                    style: AppText.caption.copyWith(
                                      color: trend.fg,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (regions.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < regions.length; i++)
                AnimatedContainer(
                  duration: AppMotion.standard,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.sageMid : AppColors.beige,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
