import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/models/api/pain_log.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import 'pain_scale_sheet.dart';

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
  final Map<BodyPart, double> _values = {};
  final Map<BodyPart, String> _notes = {};
  final Map<BodyPart, bool> _noteOpen = {};
  final Map<BodyPart, bool> _saved = {};
  final Map<BodyPart, TextEditingController> _controllers = {};

  TextEditingController _ctrlFor(BodyPart region, String initialText) {
    return _controllers.putIfAbsent(
        region, () => TextEditingController(text: _notes[region] ?? initialText));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadActiveTrainedRegions();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final regions = planProvider.activeRegions;
    final painLogProvider = context.watch<PainLogProvider>();
    final savedPainLogs = painLogProvider.todayPainLogs;

    // Ohne aktive Regionen gäbe es sonst 340 px leeren Raum: die SizedBox
    // bleibt stehen, während der PageView mangels Items nichts zeichnet.
    if (regions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _controller,
            itemCount: regions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final region = regions[i];
              // PainLog aus Isar suchen
              final existingLog = savedPainLogs.cast<PainLog?>().firstWhere(
                    (log) => log?.region == region,
                orElse: () => null,
              );
              // PainLog Werte ermitteln (Live-Eingabe hat Vorrang vor Isar, Isar hat Vorrang vor Standard)
              final value = _values[region] ?? (existingLog?.level.toDouble() ?? 4.0);
              final noteVal = _controllers[region]?.text ?? _notes[region] ?? (existingLog?.note ?? '');
              final controller = _ctrlFor(region, noteVal);
              // Logik für den Button-Status (Geändert vs. Gespeichert)
              bool isSaved = false;
              // Wenn der Nutzer gerade erst auf "Sichern" geklickt hat (für die 2-Sekunden-Animation):
              if (_saved[region] == true) {
                isSaved = true;
              }
              // Wenn bereits Daten in Isar existieren: Prüfen, ob der Nutzer etwas verändert hat
              else if (existingLog != null) {
                final hasValueChanged = _values.containsKey(region) && _values[region] != existingLog.level.toDouble();
                final hasNoteChanged = _notes.containsKey(region) && _notes[region] != existingLog.note;
                // Nur wenn Weder Slider Noch Notiz verändert wurden, gilt der Eintrag als "Gespeichert"
                isSaved = !hasValueChanged && !hasNoteChanged;
              }
              final noteOpen = _noteOpen[region] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Align(
                  alignment: Alignment.topCenter,
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
                                  "Wie geht's ${region.article} ${region.label}?",
                                  style: AppText.cardTitle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              GestureDetector(
                                onTap: () => PainScaleSheet.show(context),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.offwhite,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.beige, width: 1),
                                  ),
                                  child: SvgPicture.asset(
                                      'assets/icons/other/info-green.svg',
                                      width: 14, height: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.base),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('${value.round()}',
                                  style: AppText.screenTitle.copyWith(fontSize: 32)),
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
                              Text('10 · starke Schmerzen', style: AppText.micro),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.offwhite,
                              borderRadius:
                              BorderRadius.circular(AppRadius.input),
                              border: Border.all(
                                color: noteOpen
                                    ? AppColors.sageDeep
                                    : AppColors.beige,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                          () => _noteOpen[region] = !noteOpen),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            size: 15,
                                            color: AppColors.sageDeep),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          noteOpen
                                              ? 'Wie ging es dir?'
                                              : noteVal.isNotEmpty
                                              ? 'Notiz bearbeiten'
                                              : 'Notiz hinzufügen',
                                          style: AppText.caption.copyWith(
                                              color: AppColors.sageDeep,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (noteOpen)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 0, 14, 14),
                                    child: TextField(
                                      minLines: 2,
                                      maxLines: 3,
                                      style: AppText.body,
                                      controller: controller,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        hintText: 'z.B. Morgens steif, nach '
                                            'den Übungen lockerer …',
                                        hintStyle: AppText.caption,
                                      ),
                                      onChanged: (t) {
                                        //Button auf "Eintrag sichern" zurücksetzen
                                        setState(() => _notes[region] = t);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SecondaryButton(
                            label: isSaved ? 'Gespeichert ✓' : 'Eintrag sichern',
                            borderColor: AppColors.sage,
                            onPressed: () {
                              final now = DateTime.now();
                              final finalNote = _controllers[region]?.text ?? noteVal;
                              context.read<PainLogProvider>().addPainLog(
                                  level: value.round(),
                                  region: region,
                                  note: finalNote,
                                  date: now
                              );
                              setState(() {
                                _values.remove(region);
                                _notes.remove(region);
                                _noteOpen[region] = false;
                                _saved[region] = true;
                              });
                              Future.delayed(
                                  const Duration(milliseconds: 2000), () {
                                if (mounted) {
                                  setState(() => _saved[region] = false);
                                }
                              });
                            },
                          ),
                        ],
                      ),
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
