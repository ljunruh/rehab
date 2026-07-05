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

  // Pro Region eigener Monats-Offset (0 = aktueller Monat, -1 = letzter …).
  final Map<String, int> _monthOffsets = {};

  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

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

  List<PainLog> _entriesFor(List<PainLog> all, int year, int month) {
    final list =
        all.where((e) => e.date.year == year && e.date.month == month).toList();
    list.sort((a, b) => a.date.day.compareTo(b.date.day));
    return list;
  }

  ({String text, Color bg, Color fg}) _computeTrend(List<PainLog> entries) {
    if (entries.length < 2) {
      return (
        text: 'Noch nicht genug Daten für einen Trend.',
        bg: AppColors.offwhite,
        fg: AppColors.textSecondary,
      );
    }
    final firstHalf = entries.sublist(0, (entries.length / 2).ceil());
    final lastHalf = entries.sublist((entries.length / 2).floor());
    double avg(List<PainLog> xs) =>
        xs.map((e) => e.level).reduce((a, b) => a + b) / xs.length;
    final diff = avg(lastHalf) - avg(firstHalf);

    if (diff.abs() < 0.5) {
      return (
        text: 'Dein Schmerzlevel ist stabil geblieben.',
        bg: AppColors.offwhite,
        fg: AppColors.textSecondary,
      );
    }
    if (diff < 0) {
      return (
        text: 'Dein Schmerzlevel ist diesen Monat gesunken.',
        bg: AppColors.sageLight,
        fg: AppColors.sageDeep,
      );
    }
    if (diff >= 1.5) {
      return (
        text: 'Dein Schmerzlevel ist diesen Monat gestiegen.',
        bg: const Color(0xFFF2DCD0),
        fg: const Color(0xFF8B6353),
      );
    }
    return (
      text: 'Dein Schmerzlevel ist diesen Monat leicht gestiegen.',
      bg: const Color(0xFFF2DCD0),
      fg: const Color(0xFF8B6353),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final regions = app.painHistory.keys.toList();

    if (regions.isEmpty) {
      return AppCard(
        child: Center(
          child: Text('Noch keine Schmerz-Daten erfasst.',
              style: AppText.caption),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 388,
          child: PageView.builder(
            controller: _controller,
            itemCount: regions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final region = regions[i];
              final offset = _monthOffsets[region] ?? 0;
              final info = _monthInfo(offset);
              final allEntries = app.painHistory[region] ?? [];
              final entries = _entriesFor(allEntries, info.year, info.month);
              final trend = _computeTrend(entries);
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
                      // Kopf: Region + Ø-Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(region,
                                  style: AppText.screenTitle.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text('SCHMERZLEVEL-SKALA 1–10',
                                  style: AppText.micro),
                            ],
                          ),
                          if (avg != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.sageLight,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text('Ø ${avg.toStringAsFixed(1)}',
                                  style: AppText.cardTitle
                                      .copyWith(color: AppColors.sageDeep)),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Monatsnavigation (funktionsfähig)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
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
                                  () => _monthOffsets[region] = offset - 1),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: const Icon(Icons.chevron_left,
                                    size: 16, color: AppColors.sageDeep),
                              ),
                            ),
                            Text(info.label, style: AppText.cardTitle),
                            GestureDetector(
                              onTap: offset >= 0
                                  ? null
                                  : () => setState(() =>
                                      _monthOffsets[region] = offset + 1),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: Icon(Icons.chevron_right,
                                    size: 16,
                                    color: offset >= 0
                                        ? AppColors.textMuted
                                            .withOpacity(0.45)
                                        : AppColors.sageDeep),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Diagramm oder Leer-Hinweis für den Monat
                      if (entries.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 30),
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
                      const SizedBox(height: AppSpacing.base),

                      // Trend-Hinweis (4 Zustände)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
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
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
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
