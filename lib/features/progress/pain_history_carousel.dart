import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import 'pain_trend_chart.dart';

/// Schmerz-Verlauf-Karussell (wischbar über Körperregionen) – wie Prototyp.
/// Pro Region: Titel, "SCHMERZLEVEL-SKALA 1–10", Durchschnitts-Badge,
/// Monatsanzeige, Liniendiagramm und ein Trend-Hinweis.
class PainHistoryCarousel extends StatefulWidget {
  const PainHistoryCarousel({super.key});

  @override
  State<PainHistoryCarousel> createState() => _PainHistoryCarouselState();
}

class _PainHistoryCarouselState extends State<PainHistoryCarousel> {
  final _controller = PageController(viewportFraction: 0.96);
  int _index = 0;

  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          height: 430,
          child: PageView.builder(
            controller: _controller,
            itemCount: regions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final region = regions[i];
              final entries = app.painHistory[region] ?? [];
              final avg = entries.isEmpty
                  ? 0.0
                  : entries.map((e) => e.level).reduce((a, b) => a + b) /
                      entries.length;
              final first = entries.isNotEmpty ? entries.first.level : 0;
              final last = entries.isNotEmpty ? entries.last.level : 0;
              final improved = last < first;
              final now = DateTime.now();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AppCard(
                  child: Column(
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
                                  style: AppText.screenTitle
                                      .copyWith(fontSize: 20)),
                              const SizedBox(height: 2),
                              Text('SCHMERZLEVEL-SKALA 1–10',
                                  style: AppText.micro),
                            ],
                          ),
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

                      // Monatsanzeige
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.offwhite,
                          borderRadius:
                              BorderRadius.circular(AppRadius.input),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.chevron_left,
                                size: 18, color: AppColors.textMuted),
                            Text('${_months[now.month - 1]} ${now.year}',
                                style: AppText.cardTitle),
                            const Icon(Icons.chevron_right,
                                size: 18, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Diagramm mit X-Achse
                      PainTrendChart(entries: entries, height: 110),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1', style: AppText.micro),
                            Text('10', style: AppText.micro),
                            Text('20', style: AppText.micro),
                            Text('31', style: AppText.micro),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Hinweis-Kasten
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.sageLight,
                          borderRadius:
                              BorderRadius.circular(AppRadius.input),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 2, right: 10),
                              decoration: const BoxDecoration(
                                color: AppColors.sage,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                improved
                                    ? 'Dein Schmerzlevel ist diesen Monat gesunken.'
                                    : 'Dein Schmerzlevel ist diesen Monat stabil.',
                                style: AppText.caption.copyWith(
                                    color: AppColors.sageDeep, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
