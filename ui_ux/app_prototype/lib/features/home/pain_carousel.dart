import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// "Wie geht es dir heute?" — wischbares Schmerz-Erfassungs-Karussell.
///
/// Pro aktiver Region eine Karte mit Slider (0–10), optionaler Notiz und
/// "Eintrag sichern". Entspricht dem Pain-Quick-Log im JSX-Prototyp.
class PainCarousel extends StatefulWidget {
  const PainCarousel({super.key});

  @override
  State<PainCarousel> createState() => _PainCarouselState();
}

class _PainCarouselState extends State<PainCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  // Lokaler Eingabe-Zustand je Region (Wert, Notiz-Text, Notiz offen?).
  final Map<String, double> _values = {};
  final Map<String, String> _notes = {};
  final Map<String, bool> _noteOpen = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _article(String region) =>
      ['Schulter', 'Hüfte', 'Wade'].contains(region) ? 'deiner' : 'deinem';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final regions = app.activeRegions;

    return Column(
      children: [
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _controller,
            itemCount: regions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final region = regions[i];
              final value = _values[region] ?? 4;
              final noteOpen = _noteOpen[region] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Wie geht's ${_article(region)} $region?",
                              style: AppText.cardTitle,
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.offwhite,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.beige, width: 1),
                            ),
                            child: const Icon(Icons.info_outline,
                                size: 13, color: AppColors.sageDeep),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${value.round()}',
                              style: AppText.screenTitle
                                  .copyWith(fontSize: 32)),
                          const SizedBox(width: 6),
                          Text('/ 10', style: AppText.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          activeTrackColor: AppColors.sageDeep,
                          inactiveTrackColor: AppColors.beige,
                          thumbColor: AppColors.white,
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 16),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 11),
                        ),
                        child: Slider(
                          value: value,
                          min: 0,
                          max: 10,
                          onChanged: (v) =>
                              setState(() => _values[region] = v.roundToDouble()),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0 · kein Schmerz', style: AppText.micro),
                          Text('10 · stärkster', style: AppText.micro),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (noteOpen)
                        TextField(
                          minLines: 1,
                          maxLines: 2,
                          style: AppText.body,
                          decoration: InputDecoration(
                            hintText: 'Notiz (optional)',
                            hintStyle: AppText.caption,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor: AppColors.offwhite,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input),
                              borderSide:
                                  const BorderSide(color: AppColors.beige),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input),
                              borderSide:
                                  const BorderSide(color: AppColors.beige),
                            ),
                          ),
                          onChanged: (t) => _notes[region] = t,
                        )
                      else
                        SecondaryButton(
                          label: 'Notiz hinzufügen',
                          icon: Icons.edit_outlined,
                          onPressed: () =>
                              setState(() => _noteOpen[region] = true),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      SecondaryButton(
                        label: 'Eintrag sichern',
                        onPressed: () {
                          final now = DateTime.now();
                          app.addPainLog(PainLog(
                            level: value.round(),
                            region: region,
                            note: _notes[region] ?? '',
                            date: now,
                            dateKey: PainLog.keyOf(now),
                          ));
                          setState(() {
                            _noteOpen[region] = false;
                            _notes[region] = '';
                          });
                        },
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
          _Dots(count: regions.length, active: _index),
        ],
      ],
    );
  }
}

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
