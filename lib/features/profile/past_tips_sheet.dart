import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class _PastTip {
  final String date;
  final String title;
  final String body;
  const _PastTip(this.date, this.title, this.body);
}

const List<_PastTip> _pastTips = [
  _PastTip(
    '02. Jun 2025',
    'Geh an die frische Luft',
    'Schon 15 Minuten im Freien können deinen Cortisolspiegel senken und '
        'deine Stimmung heben. Kein Sport nötig – einfach einen kurzen '
        'Spaziergang machen, am besten ohne Kopfhörer.',
  ),
  _PastTip(
    '28. Mai 2025',
    'Grüner Smoothie für zwischendurch',
    'Mixe Spinat, eine Banane, etwas Ingwer und Hafermilch. Das liefert '
        'Magnesium, Kalium und natürliche Energie – ohne Zucker-Crash.',
  ),
  _PastTip(
    '21. Mai 2025',
    'Weniger Bildschirmzeit vor dem Schlafen',
    'Das blaue Licht von Smartphones hemmt die Melatoninproduktion. '
        'Versuche, 30 Minuten vor dem Schlafen das Handy wegzulegen – dein '
        'Schlaf wird tiefer und erholsamer.',
  ),
  _PastTip(
    '14. Mai 2025',
    'Wasser als erstes am Morgen',
    'Ein großes Glas Wasser direkt nach dem Aufwachen hilft deinem Körper, '
        'nach der Nacht wieder in Schwung zu kommen und den Stoffwechsel '
        'anzuregen.',
  ),
  _PastTip(
    '07. Mai 2025',
    'Bewusste Atempause',
    'Atme dreimal tief ein und langsam aus. Diese einfache Übung aktiviert '
        'dein parasympathisches Nervensystem und reduziert Stress in '
        'Sekunden – jederzeit und überall machbar.',
  ),
];

/// "Vergangene Tages-Tipps"-Sheet im Profil-Drawer (Person 4).
///
/// Entspricht dem `tipsOpen`-Sheet im JSX-Prototyp: eine Liste bereits
/// freigeschalteter Tages-Tipps, jede Karte auf Antippen auf-/zuklappbar.
class PastTipsSheet extends StatelessWidget {
  const PastTipsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => const PastTipsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vergangene Tages-Tipps',
                    style: AppText.screenTitle.copyWith(fontSize: 18)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.offwhite,
                      borderRadius:
                          BorderRadius.circular(AppRadius.iconSmall),
                    ),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hier findest du alle Tages-Tipps, die du bisher '
              'freigeschaltet hast.',
              style: AppText.caption.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.base),
            for (final tip in _pastTips) _PastTipCard(tip: tip),
          ],
        ),
      ),
    );
  }
}

class _PastTipCard extends StatefulWidget {
  final _PastTip tip;
  const _PastTipCard({required this.tip});

  @override
  State<_PastTipCard> createState() => _PastTipCardState();
}

class _PastTipCardState extends State<_PastTipCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_open,
                          size: 16, color: AppColors.sageDeep),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.tip.date, style: AppText.micro),
                          const SizedBox(height: 2),
                          Text(widget.tip.title,
                              style: AppText.cardTitle
                                  .copyWith(height: 1.3)),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.25 : 0,
                      duration: AppMotion.standard,
                      child: const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (_open)
                Padding(
                  padding: const EdgeInsets.fromLTRB(64, 0, 16, 14),
                  child: Text(widget.tip.body,
                      style: AppText.caption.copyWith(height: 1.6)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
