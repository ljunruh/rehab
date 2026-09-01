import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../data/models/alltag_guide.dart';
import '../../data/demo/alltag_data.dart';
import '../../navigation/screen_header.dart';
import '../../core/region_icons.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 2 — PLÄNE & TRAINING                              │
/// │  Verantwortlich für: PlansScreen, PlanDetail, PlanCreate,│
/// │  PlanTraining, Empfehlungs-/Bibliotheks-Flows.           │
/// │  Aktionen über UiState.savePlan / deletePlan / …   │
/// └──────────────────────────────────────────────────────────┘
///
/// Entspricht PlansScreen im JSX-Prototyp (V12):
///  - "Meine Pläne": aktive Pläne als wischbare Karten (Bearbeiten/
///    Archiv/Löschen), sortiert nach den 5 anatomischen Regionen
///    zuerst, dann Lifestyle-Pläne.
///  - "Meine Schonung im Alltag": gespeicherte (gebookmarkte)
///    Situationskarten, nur sichtbar wenn welche gespeichert sind.
///  - "Schonung im Alltag" → "Beschwerdebezogen": ein rotierendes
///    Fenster von 3 Situationskarten mit Reload-Button.
class PlansScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final ValueChanged<String> onOpenPlan;

  const PlansScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenPlan,
  });

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  static const int _situWindow = 3;
  int _situStart = 0;
  bool _situSpin = false;
  final Set<String> _savedGuideIds = {'sit-knie'};
  String? _confirmDeleteId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PlanProvider>();
    });
  }

  void _reloadSitu() {
    if (_situSpin) return;
    setState(() => _situSpin = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _situStart += _situWindow;
        _situSpin = false;
      });
    });
  }

  void _toggleSavedGuide(String id) {
    setState(() {
      if (_savedGuideIds.contains(id)) {
        _savedGuideIds.remove(id);
      } else {
        _savedGuideIds.add(id);
      }
    });
  }

  /*
  int _planDuration(Plan plan, UiState app) {
    var total = 0;
    for (final exercise in plan.exercises) {
      for (final e in app.library) {
        if (e.id == id) {
          total += int.tryParse(e.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          break;
        }
      }
    }
    return total;
  }
  */

  void _openGuide(BuildContext context, AlltagGuide guide) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _GuideDetailSheet(
        guide: guide,
        saved: _savedGuideIds.contains(guide.id),
        onToggleSaved: () {
          _toggleSavedGuide(guide.id);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    //[API]: LocalStorage Pläne eingefügt
    //final profile = app.profile; // UI auskommentiert
    final user = context.watch<UserProvider>();
    final plan = context.watch<PlanProvider>();
    final activePlans = plan.activePlans;

    // Anatomische Standard-Regionen zuerst, dann Lifestyle-Pläne.
    /* UI auskommentiert
    const anatomicalRegions = ['Knie', 'Schulter', 'Rücken', 'Nacken', 'Hüfte'];
    final anatomicalPlans = [
      for (final r in anatomicalRegions)
        for (final p in app.plans)
          if (p.region == r && !p.archived) p,
    ];
    final lifestylePlans = app.plans
        .where((p) => !p.archived && !anatomicalRegions.contains(p.region))
        .toList();
    final activePlans = [...anatomicalPlans, ...lifestylePlans];
    */

    // Gespeicherte Schonungs-Situationskarten.
    final savedGuides = AlltagData.schonung
        .where((g) => _savedGuideIds.contains(g.id))
        .toList();

    // Rotierendes Fenster für "Beschwerdebezogen" (aktive Plan-Regionen
    // zuerst, bereits gespeicherte ausgeblendet).
    final activeRegions = activePlans.map((p) => p.region).toSet();
    final situationCards = [
      for (final g in AlltagData.schonung)
        if (activeRegions.contains(g.region) && !_savedGuideIds.contains(g.id)) g,
      for (final g in AlltagData.schonung)
        if (!activeRegions.contains(g.region) && !_savedGuideIds.contains(g.id)) g,
    ];
    List<AlltagGuide> visibleSitu = [];
    if (situationCards.isNotEmpty) {
      final off = _situStart % situationCards.length;
      final rotated = [...situationCards.skip(off), ...situationCards.take(off)];
      visibleSitu = rotated.take(_situWindow).toList();
    }

    final planToDelete = _confirmDeleteId == null
        ? null
        : app.plans.where((p) => p.id == _confirmDeleteId).firstOrNull;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
          children: [
            ScreenHeader(
              greeting: 'Trainingspläne',
              initials: user.initials,
              onAvatarTap: widget.onOpenProfile,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //[API]: LocalStorage Pläne eingefügt
                  Text('MEINE PLÄNE', style: AppText.micro),
                  const SizedBox(height: AppSpacing.sm),
                  ...activePlans.map(
                    (p) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _SwipeablePlanCard(
                        plan: p,
                        duration: p.duration,
                        //TODO[API]: DemoData ID, damit UI nicht kaputt geht. Wird später ersetzt p.id
                        onOpen: () => widget.onOpenPlan(p.id),
                        onArchive: () => plan.archivePlan(p.id),
                        onRequestDelete: () =>
                            setState(() => _confirmDeleteId = p.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // "Plan hinzufügen" – rein dekorativ, wie im Prototyp
                  // (Pläne werden über den "+"-Button in der Navigation
                  // angelegt).
                  CustomPaint(
                    painter: _DashedBorderPainter(
                      color: AppColors.mint,
                      radius: 22,
                      strokeWidth: 1.5,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add,
                              size: 15, color: AppColors.sageDeep),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Plan hinzufügen',
                              style: AppText.caption.copyWith(
                                  color: AppColors.sageDeep,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),

                  if (savedGuides.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('MEINE SCHONUNG IM ALLTAG', style: AppText.micro),
                    const SizedBox(height: AppSpacing.sm),
                    ...savedGuides.map(
                      (g) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SavedGuideRow(
                          guide: g,
                          onTap: () => _openGuide(context, g),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sectionGap),
                  Text('Schonung im Alltag',
                      style: AppText.screenTitle.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    'Kleine Anpassungen im Alltag, die deine Beschwerden '
                    'spürbar entlasten',
                    style: AppText.caption.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BESCHWERDEBEZOGEN',
                          style: AppText.micro.copyWith(fontSize: 11)),
                      GestureDetector(
                        onTap: _reloadSitu,
                        child: AnimatedRotation(
                          turns: _situSpin ? 1 : 0,
                          duration: const Duration(milliseconds: 650),
                          child: SvgPicture.asset('assets/icons/other/reload.svg',
                              width: 16, height: 16,
                              colorFilter: const ColorFilter.mode(AppColors.sage, BlendMode.srcIn)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: _situSpin ? 0.35 : 1,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: 168,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH),
                  children: [
                    for (final g in visibleSitu)
                      Padding(
                        padding:
                            const EdgeInsets.only(right: AppSpacing.md),
                        child: _SituationSliderCard(
                          guide: g,
                          onTap: () => _openGuide(context, g),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),

        // Lösch-Bestätigungs-Sheet wird über showModalBottomSheet nicht
        // hier, sondern reaktiv unten ausgelöst.
        if (_confirmDeleteId != null)
          _DeleteConfirmOverlay(
            planName: planToDelete?.name ?? '',
            onCancel: () => setState(() => _confirmDeleteId = null),
            onConfirm: () {
              plan.deletePlan(_confirmDeleteId!);
              setState(() => _confirmDeleteId = null);
            },
          ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Zeichnet eine gestrichelte, abgerundete Umrandung um sein Kind.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.gapWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Wischbare Plan-Karte: Antippen öffnet den Plan, nach links wischen
/// zeigt Bearbeiten/Archiv/Löschen. Entspricht SwipeablePlanCard im
/// JSX-Prototyp exakt (Kreis-Avatar, Rubrik-Label, Region als Titel,
/// "X Übungen · ca. Y Min").
class _SwipeablePlanCard extends StatefulWidget {
  final Plan plan;
  final int duration;
  final VoidCallback onOpen;
  final VoidCallback onArchive;
  final VoidCallback onRequestDelete;

  const _SwipeablePlanCard({
    required this.plan,
    required this.duration,
    required this.onOpen,
    required this.onArchive,
    required this.onRequestDelete,
  });

  @override
  State<_SwipeablePlanCard> createState() => _SwipeablePlanCardState();
}

class _SwipeablePlanCardState extends State<_SwipeablePlanCard> {
  static const _editW = 58.0;
  static const _archiveW = 58.0;
  static const _deleteW = 58.0;
  static const _fullSnap = -(_editW + _archiveW + _deleteW);
  static const _editSnap = -_editW;
  static const _archiveThreshold = 36.0;
  static const _deleteThreshold = 100.0;
  static const _fullSwipeTrigger = 220.0;

  double _offset = 0;

  static const _rubrikMap = [
    ['Kraft', 'Kräftigung', 'Kraft'],
    ['Mobil', 'Beweglich', 'Entlastung', 'Dehnung', 'Mobilisation'],
    ['Koordination', 'Stabilität', 'Gleichgewicht', 'Haltung', 'Koordination'],
    ['Entspannung', 'Ruhe', 'Entspannung'],
  ];

  String _rubrikLabel(String goal) {
    for (final entry in _rubrikMap) {
      final keys = entry.sublist(0, entry.length - 1);
      if (keys.any((k) => goal.contains(k))) return entry.last;
    }
    return 'Mobilisation';
  }

  void _snapTo(double value) => setState(() => _offset = value);

  @override
  Widget build(BuildContext context) {
    final abs = _offset.abs();
    final editVisible = abs > 8;
    final archiveVisible = abs > 36;
    final deleteVisible = abs > 90;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          // Action-Hintergrund
          Positioned.fill(
            child: Row(
              children: [
                const Spacer(),
                _ActionBtn(
                  width: _editW,
                  color: AppColors.sageDeep,
                  icon: Icons.edit_outlined,
                  label: 'Bearbeiten',
                  visible: editVisible,
                  onTap: () => _snapTo(0),
                ),
                _ActionBtn(
                  width: _archiveW,
                  color: const Color(0xFFC9A83C),
                  icon: Icons.archive_outlined,
                  label: 'Archiv',
                  visible: archiveVisible,
                  onTap: () {
                    _snapTo(0);
                    widget.onArchive();
                  },
                ),
                _ActionBtn(
                  width: _deleteW,
                  color: const Color(0xFFC46A52),
                  icon: Icons.delete_outline,
                  label: 'Löschen',
                  visible: deleteVisible,
                  onTap: () {
                    _snapTo(0);
                    widget.onRequestDelete();
                  },
                ),
              ],
            ),
          ),
          // Vordergrund-Karte
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              setState(() {
                _offset = (_offset + details.delta.dx).clamp(-300.0, 0.0);
              });
            },
            onHorizontalDragEnd: (_) {
              final abs = _offset.abs();
              if (abs >= _fullSwipeTrigger) {
                _snapTo(0);
                widget.onRequestDelete();
              } else if (abs >= _deleteThreshold) {
                _snapTo(_fullSnap);
              } else if (abs >= _archiveThreshold) {
                _snapTo(_editSnap);
              } else {
                _snapTo(0);
              }
            },
            onTap: () {
              if (_offset != 0) {
                _snapTo(0);
                return;
              }
              widget.onOpen();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(_offset, 0, 0),
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: () {
                      final icon = RegionIcons.forBodyPart(widget.plan.region);
                      return icon == null
                          ? null
                          : SvgPicture.asset(icon, width: 26, height: 26);
                    }(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_rubrikLabel(widget.plan.goal.label).toUpperCase(),
                            style: AppText.micro),
                        const SizedBox(height: 2),
                        Text(widget.plan.region.label,
                            style: AppText.cardTitle.copyWith(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.plan.exercises.length} Übungen · ca. ${widget.duration} Min',
                          style: AppText.micro,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final double width;
  final Color color;
  final IconData icon;
  final String label;
  final bool visible;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.width,
    required this.color,
    required this.icon,
    required this.label,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: width,
          color: color,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.white),
              const SizedBox(height: 3),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zeile für eine gespeicherte ("Meine Schonung im Alltag") Situationskarte.
class _SavedGuideRow extends StatelessWidget {
  final AlltagGuide guide;
  final VoidCallback onTap;
  const _SavedGuideRow({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: guide.bg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: SvgPicture.asset('assets/icons/other/reticle.svg',
                  width: 18, height: 18,
                  colorFilter: ColorFilter.mode(guide.fg, BlendMode.srcIn)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guide.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.cardTitle),
                  const SizedBox(height: 2),
                  Text('${guide.tag} · ${guide.sections.length} Themen',
                      style: AppText.micro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Karte im horizontalen "Beschwerdebezogen"-Slider.
class _SituationSliderCard extends StatelessWidget {
  final AlltagGuide guide;
  final VoidCallback onTap;
  const _SituationSliderCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: guide.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.onDarkIconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset('assets/icons/other/reticle.svg',
                  width: 18, height: 18,
                  colorFilter: ColorFilter.mode(guide.fg, BlendMode.srcIn)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(guide.tag.toUpperCase(),
                style: AppText.micro.copyWith(
                    color: guide.fg, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(guide.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardTitle.copyWith(
                    color: guide.fg, fontSize: 13, height: 1.25)),
            const SizedBox(height: 8),
            Text(guide.subtitle,
                style: AppText.micro.copyWith(
                    color: guide.fg.withOpacity(0.6),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

/// Detail-Sheet für eine Schonungs-Situationskarte: Cover + Accordion +
/// "Zu meiner Schonung hinzufügen/entfernen"-Button.
class _GuideDetailSheet extends StatefulWidget {
  final AlltagGuide guide;
  final bool saved;
  final VoidCallback onToggleSaved;

  const _GuideDetailSheet({
    required this.guide,
    required this.saved,
    required this.onToggleSaved,
  });

  @override
  State<_GuideDetailSheet> createState() => _GuideDetailSheetState();
}

class _GuideDetailSheetState extends State<_GuideDetailSheet> {
  int _openIdx = 0;

  @override
  Widget build(BuildContext context) {
    final guide = widget.guide;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
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
                ),
                const SizedBox(height: 6),

                // Cover
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 24),
                  decoration: BoxDecoration(
                    color: guide.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.onDarkIconBg,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SvgPicture.asset('assets/icons/other/reticle.svg',
                            width: 26, height: 26,
                            colorFilter: ColorFilter.mode(guide.fg, BlendMode.srcIn)),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(guide.tag.toUpperCase(),
                          style: AppText.micro.copyWith(color: guide.fg)),
                      const SizedBox(height: 6),
                      Text(guide.title,
                          style: AppText.screenTitle.copyWith(
                              color: guide.fg, fontSize: 25)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in guide.sections)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.onDarkIconBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s.title,
                                  style: AppText.micro
                                      .copyWith(color: guide.fg)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Accordion
                for (var i = 0; i < guide.sections.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _AccordionItem(
                      section: guide.sections[i],
                      open: _openIdx == i,
                      onTap: () => setState(
                          () => _openIdx = _openIdx == i ? -1 : i),
                    ),
                  ),

                const SizedBox(height: AppSpacing.base),
                GestureDetector(
                  onTap: widget.onToggleSaved,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.saved ? AppColors.offwhite : AppColors.sage,
                      borderRadius: BorderRadius.circular(999),
                      border: widget.saved
                          ? Border.all(color: AppColors.sage)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.saved ? Icons.check : Icons.add,
                          size: 16,
                          color: widget.saved
                              ? AppColors.sageDeep
                              : AppColors.white,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          widget.saved
                              ? 'Von meiner Schonung entfernen'
                              : 'Zu meiner Schonung hinzufügen',
                          style: AppText.button.copyWith(
                            color: widget.saved
                                ? AppColors.sageDeep
                                : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccordionItem extends StatelessWidget {
  final GuideSection section;
  final bool open;
  final VoidCallback onTap;

  const _AccordionItem({
    required this.section,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.beige,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(section.icon,
                        size: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(section.title,
                        style: AppText.cardTitle
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: AppMotion.standard,
                    child: const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.intro,
                      style: AppText.caption.copyWith(height: 1.55)),
                  const SizedBox(height: AppSpacing.md),
                  for (final item in section.items)
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
                                style: AppText.body.copyWith(height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DeleteConfirmOverlay extends StatelessWidget {
  final String planName;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DeleteConfirmOverlay({
    required this.planName,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onCancel,
        child: Container(
          color: const Color(0x521F2421),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 300,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAE6DC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 22, color: Color(0xFFC46A52)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Plan löschen?',
                      style: AppText.screenTitle.copyWith(fontSize: 20)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Möchtest du "$planName" wirklich löschen? Diese Aktion '
                    'kann nicht rückgängig gemacht werden.',
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Abbrechen',
                          onPressed: onCancel,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GestureDetector(
                          onTap: onConfirm,
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC46A52),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text('Löschen',
                                style: AppText.button
                                    .copyWith(color: AppColors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
