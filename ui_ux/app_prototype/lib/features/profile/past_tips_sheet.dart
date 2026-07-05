import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class _PastTip {
  final String tag;
  final String title;
  final String intro;
  final String heading;
  final List<String> items;
  final String outro;
  const _PastTip({
    required this.tag,
    required this.title,
    required this.intro,
    required this.heading,
    required this.items,
    this.outro = '',
  });
}

// 1:1 aus ALLTAG_TIPS im JSX-Prototyp übernommen.
const List<_PastTip> _pastTips = [
  _PastTip(
    tag: 'Sitzhaltung',
    title: 'Aufrecht & entspannt sitzen',
    intro:
        'Die beste Sitzhaltung ist die, die du regelmäßig veränderst. Mit '
        'ein paar Grundregeln entlastest du Wirbelsäule und Nacken trotzdem '
        'deutlich.',
    heading: 'Dein Sitz-Check',
    items: [
      'Becken leicht nach vorne aufgerichtet, nicht rundrücken',
      'Unterer Rücken an der Lehne abgestützt',
      'Schultern locker hängen lassen',
      'Füße flach am Boden, Knie etwa 90°',
    ],
    outro:
        'Wechsle alle paar Minuten leicht die Position – dynamisches Sitzen '
        'ist gesünder als starres Stillhalten.',
  ),
  _PastTip(
    tag: 'Arbeitsplatz',
    title: 'Bildschirm auf Augenhöhe',
    intro:
        'Ein zu tief stehender Bildschirm zwingt den Kopf nach vorne und '
        'belastet die Halswirbelsäule – eine der häufigsten Ursachen für '
        'Nackenbeschwerden am Schreibtisch.',
    heading: 'Richtig einstellen',
    items: [
      'Obere Bildschirmkante auf oder knapp unter Augenhöhe',
      'Abstand etwa eine Armlänge',
      'Bildschirm leicht nach hinten geneigt',
      'Laptop ggf. erhöhen und externe Tastatur nutzen',
    ],
  ),
  _PastTip(
    tag: 'Heben',
    title: 'Aus den Beinen heben',
    intro:
        'Ob Wasserkiste oder Wäschekorb – falsches Heben aus dem Rücken ist '
        'ein typischer Auslöser für akute Rückenschmerzen. Die Kraft kommt '
        'aus den Beinen.',
    heading: 'So hebst du rückenschonend',
    items: [
      'In die Knie gehen, Rücken gerade halten',
      'Last möglichst nah am Körper',
      'Mit den Beinen hochdrücken, nicht mit dem Rücken',
      'Beim Tragen nicht zusätzlich verdrehen',
    ],
  ),
  _PastTip(
    tag: 'Bewegung',
    title: 'Position regelmäßig wechseln',
    intro:
        'Kein Körper ist fürs stundenlange Verharren gemacht. Der '
        'wichtigste ergonomische Hebel ist Abwechslung – die nächste '
        'Haltung ist immer die beste.',
    heading: 'Einfach umsetzen',
    items: [
      'Timer auf 30–60 Minuten stellen',
      'Zwischen Sitzen und Stehen wechseln',
      'Kurz aufstehen, strecken, ein paar Schritte gehen',
      'Telefonate im Stehen führen',
    ],
  ),
  _PastTip(
    tag: 'Arbeitsplatz',
    title: 'Neutrale Handgelenke',
    intro:
        'Abgeknickte Handgelenke an Maus und Tastatur reizen auf Dauer '
        'Sehnen und Nerven. Eine neutrale, gerade Position beugt vor.',
    heading: 'Worauf du achtest',
    items: [
      'Handgelenke gerade, nicht nach oben oder unten knicken',
      'Unterarme locker auf dem Tisch auflegen',
      'Maus nah an der Tastatur positionieren',
      'Schultern dabei locker lassen',
    ],
  ),
  _PastTip(
    tag: 'Technik',
    title: 'Handy auf Augenhöhe',
    intro:
        'Der gesenkte Blick aufs Handy belastet den Nacken enorm – man '
        'spricht vom „Handy-Nacken". Schon eine kleine Änderung der '
        'Haltung hilft.',
    heading: 'Besser machen',
    items: [
      'Smartphone höher Richtung Augenhöhe halten',
      'Kopf möglichst aufrecht lassen',
      'Längeres Tippen lieber im Stehen oder Sitzen mit Auflage',
      'Zwischendurch den Nacken sanft kreisen lassen',
    ],
  ),
];

/// "Vergangene Tages-Tipps"-Sheet im Profil-Drawer (Person 4).
///
/// Entspricht dem `tipsOpen`-Sheet im JSX-Prototyp: eine Liste bereits
/// freigeschalteter Tages-Tipps (Inhalte 1:1 aus `ALLTAG_TIPS`
/// übernommen), jede Karte auf Antippen auf-/zuklappbar.
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
                      child: const Icon(Icons.lightbulb_outline,
                          size: 16, color: AppColors.sageDeep),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.tip.tag.toUpperCase(),
                              style: AppText.micro),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.tip.intro,
                          style: AppText.caption.copyWith(height: 1.6)),
                      const SizedBox(height: AppSpacing.md),
                      Text(widget.tip.heading,
                          style: AppText.cardTitle
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in widget.tip.items)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 7),
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.sage,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(item,
                                    style: AppText.body
                                        .copyWith(height: 1.5)),
                              ),
                            ],
                          ),
                        ),
                      if (widget.tip.outro.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(widget.tip.outro,
                            style:
                                AppText.caption.copyWith(height: 1.6)),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
