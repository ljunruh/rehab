import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// "Womit fängst du heute an?" — wischbares Karussell mit Trainings-Startern
/// je Region. Jede Karte: Rubrik-Eyebrow, Region, Übungszahl/Minuten,
/// Status-Fortschritt und ein "<Region>-Training starten"-Button.
/// Entspricht dem Today-Regions-Slider im JSX-Prototyp.
class StarterCarousel extends StatefulWidget {
  final ValueChanged<String> onStartRegion;
  const StarterCarousel({super.key, required this.onStartRegion});

  @override
  State<StarterCarousel> createState() => _StarterCarouselState();
}

class _StarterCarouselState extends State<StarterCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rubrik (Kraft/Mobilisation/Koordination/Entspannung) aus dem Ziel ableiten.
  ({String label, IconData icon}) _rubrik(String goal) {
    final g = goal.toLowerCase();
    if (g.contains('kraft') || g.contains('kräftig')) {
      return (label: 'KRAFT', icon: Icons.bolt);
    }
    if (g.contains('koordin') ||
        g.contains('stabil') ||
        g.contains('gleichgewicht') ||
        g.contains('haltung')) {
      return (label: 'KOORDINATION', icon: Icons.gps_fixed);
    }
    if (g.contains('entspann') || g.contains('ruhe')) {
      return (label: 'ENTSPANNUNG', icon: Icons.spa);
    }
    return (label: 'MOBILISATION', icon: Icons.waves);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final regions = app.activeRegions;

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controller,
            itemCount: regions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final region = regions[i];
              final data = app.starterFor(region);
              final isActive = i == _index;
              final rubrik = _rubrik(data.goal);

              final statusText = data.total == 0
                  ? 'Heute nichts geplant'
                  : data.done == data.total
                      ? 'Alles erledigt'
                      : data.done == 0
                          ? 'Noch offen'
                          : '${data.done} von ${data.total} erledigt';
              final pct = data.total > 0 ? data.done / data.total : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  background: isActive ? AppColors.white : AppColors.offwhite,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: AppColors.mint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rubrik.label, style: AppText.micro),
                                const SizedBox(height: 2),
                                Text(region,
                                    style: AppText.cardTitle
                                        .copyWith(fontSize: 17)),
                                const SizedBox(height: 2),
                                Text(
                                  data.total == 0
                                      ? 'Keine Übungen'
                                      : '${data.total} ${data.total == 1 ? 'Übung' : 'Übungen'} · ca. ${data.minutes} Min.',
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('STATUS', style: AppText.micro),
                          Text(statusText,
                              style: AppText.label
                                  .copyWith(color: AppColors.sageDeep)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: AppColors.beige,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.sageMid),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      PrimaryButton(
                        label: '$region-Training starten',
                        icon: Icons.arrow_forward,
                        disabled: data.total == 0,
                        onPressed: data.total == 0
                            ? null
                            : () => widget.onStartRegion(region),
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
          _Dots(count: regions.length, active: _index),
        ],
      ],
    );
  }
}

/// Pagination-Punkte (aktiver Punkt ist breiter).
class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.standard,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == active ? AppColors.sageMid : AppColors.beige,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
