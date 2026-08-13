import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Interaktive Körper-Region-Auswahl (Vorderseite / Rückseite).
///
/// Zeichnet eine anatomische Muskelfigur (SVG, in Sage-Grün eingefärbt) und die
/// antippbaren Regionen in **einer einzigen Zeichenebene** ([CustomPaint]):
/// Die SVG wird als [ui.Picture] geladen und zusammen mit den Region-Markern auf
/// dieselbe Canvas gemalt. So können Figur und Marker prinzipiell nicht
/// gegeneinander verrutschen (kein Layer-Drift beim Scrollen).
///
/// Ausgewählte Regionen werden grün gefüllt, nicht gewählte gestrichelt
/// umrandet. Vorder-/Rückseite umschaltbar.
///
/// Von den 14 Beschwerdebereichen sind 12 direkt auf der Figur antippbar;
/// `Gleichgewichtsprobleme` (kein Körperort) und `Wirbelsäulenprobleme`
/// (überlappt die Rücken-Unterregionen) werden als Chips darunter angeboten.
///
/// Grafik: „Muscles front and back" von Tomáš Kebert & umimeto.org (nach
/// OpenStax), CC BY-SA 4.0 – umgefärbt. Quelle/Lizenz siehe Impressum.
///
/// [selected]/[onChanged] arbeiten mit den deutschen Region-Labels
/// (kompatibel zu `profile.regions`).
class BodyMapSelector extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const BodyMapSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<BodyMapSelector> createState() => _BodyMapSelectorState();
}

/// Figur-Koordinatensystem: identisch zur SVG-viewBox (Breite × Höhe).
const double _kFigW = 205;
const double _kFigH = 354.43;

const String _kFrontAsset = 'assets/body/koerper_front.svg';
const String _kBackAsset = 'assets/body/koerper_back.svg';

/// Temporäres Messgitter zum Kalibrieren der Hotspots (rot). Vor Release false.
const bool _kDebugGrid = false;

/// Ein antippbarer Bereich (Ellipse) in Figur-Koordinaten.
class _Spot {
  final double cx, cy, rx, ry;
  const _Spot(this.cx, this.cy, this.rx, this.ry);
}

class _Reg {
  final String label;
  final List<_Spot> spots;
  const _Reg(this.label, this.spots);
}

// Auf der Figur antippbare Regionen (Namen unverändert, kompatibel zum KG).
const List<_Reg> _kFront = [
  _Reg('Atemwegsproblem', [_Spot(101, 100, 30, 17)]),
  _Reg('Schulterprobleme', [_Spot(62, 95, 18, 15), _Spot(140, 95, 18, 15)]),
  _Reg('Rumpfmuskelschwäche', [_Spot(101, 138, 24, 27)]),
  _Reg('Hüftprobleme', [_Spot(101, 182, 30, 15)]),
  _Reg('Handgelenkprobleme', [_Spot(30, 199, 14, 14), _Spot(172, 199, 14, 14)]),
  _Reg('Knieschmerzen', [_Spot(86, 247, 13, 14), _Spot(117, 247, 13, 14)]),
  _Reg('Sprunggelenkprobleme', [_Spot(88, 322, 11, 11), _Spot(116, 322, 11, 11)]),
];

const List<_Reg> _kBack = [
  _Reg('Nackenprobleme', [_Spot(113, 60, 14, 9)]),
  _Reg('Schulterprobleme', [_Spot(68, 95, 18, 15), _Spot(152, 95, 18, 15)]),
  _Reg('Probleme im oberen Rücken', [_Spot(113, 100, 27, 14)]),
  _Reg('Rückenprobleme', [_Spot(113, 130, 25, 14)]),
  _Reg('Probleme im unteren Rücken', [_Spot(113, 156, 27, 13)]),
  _Reg('Oberschenkelrückseiten-Beschwerden',
      [_Spot(96, 220, 15, 25), _Spot(130, 220, 15, 25)]),
  _Reg('Sprunggelenkprobleme', [_Spot(98, 320, 11, 11), _Spot(128, 320, 11, 11)]),
];

/// Beschwerdebereiche, die nicht sinnvoll als Figur-Hotspot funktionieren
/// (kein eindeutiger Körperort bzw. Überlappung) – als Chips wählbar.
const List<String> _kExtra = ['Wirbelsäulenprobleme', 'Gleichgewichtsprobleme'];

class _BodyMapSelectorState extends State<BodyMapSelector> {
  bool _back = false;
  ui.Picture? _frontPic, _backPic;
  Size _frontSize = const Size(_kFigW, _kFigH);
  Size _backSize = const Size(_kFigW, _kFigH);

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  Future<void> _loadPictures() async {
    final f = await vg.loadPicture(const SvgAssetLoader(_kFrontAsset), null);
    final b = await vg.loadPicture(const SvgAssetLoader(_kBackAsset), null);
    if (!mounted) return;
    setState(() {
      _frontPic = f.picture;
      _frontSize = f.size;
      _backPic = b.picture;
      _backSize = b.size;
    });
  }

  @override
  void dispose() {
    _frontPic?.dispose();
    _backPic?.dispose();
    super.dispose();
  }

  List<_Reg> get _regs => _back ? _kBack : _kFront;

  void _toggle(String label) {
    final next = List<String>.from(widget.selected);
    next.contains(label) ? next.remove(label) : next.add(label);
    widget.onChanged(next);
  }

  void _handleTap(Offset local, double w, double h) {
    final sx = local.dx / w * _kFigW;
    final sy = local.dy / h * _kFigH;
    for (final r in _regs) {
      for (final s in r.spots) {
        final dx = (sx - s.cx) / s.rx;
        final dy = (sy - s.cy) / s.ry;
        if (dx * dx + dy * dy <= 1.0) {
          _toggle(r.label);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Vorderseite / Rückseite Umschalter ──
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.offwhite,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.beige),
          ),
          child: Row(
            children: [
              _sideTab('Vorderseite', !_back, () => setState(() => _back = false)),
              _sideTab('Rückseite', _back, () => setState(() => _back = true)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // ── Figur + antippbare Regionen (eine gemeinsame Ebene) ──
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth.clamp(180.0, 260.0);
            final h = w * (_kFigH / _kFigW);
            return SizedBox(
              width: w,
              height: h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _handleTap(d.localPosition, w, h),
                child: CustomPaint(
                  painter: _FigurePainter(
                    picture: _back ? _backPic : _frontPic,
                    pictureSize: _back ? _backSize : _frontSize,
                    regions: _regs,
                    selected: widget.selected,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Weitere Bereiche (nicht als Hotspot sinnvoll) ──
        Text('Weitere Bereiche', style: AppText.micro),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final r in _kExtra)
              AppChip(
                label: r,
                active: widget.selected.contains(r),
                onTap: () => _toggle(r),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Zusammenfassung ──
        Text(
          '${widget.selected.length} ${widget.selected.length == 1 ? 'Eintrag' : 'Einträge'} ausgewählt',
          style: AppText.caption,
        ),
        if (widget.selected.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final s in widget.selected) AppTag(s, variant: TagVariant.goal),
            ],
          ),
        ],
      ],
    );
  }

  Widget _sideTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: AppText.button.copyWith(
              color: active ? AppColors.sageDeep : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Malt die SVG-Figur (als [ui.Picture]) und darüber die Region-Marker auf
/// **dieselbe** Canvas – dadurch ist eine perfekte Deckung garantiert.
class _FigurePainter extends CustomPainter {
  final ui.Picture? picture;
  final Size pictureSize;
  final List<_Reg> regions;
  final List<String> selected;

  _FigurePainter({
    required this.picture,
    required this.pictureSize,
    required this.regions,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Figur: viewBox-Koordinaten → Widget-Größe skalieren und zeichnen.
    if (picture != null) {
      canvas.save();
      canvas.scale(
        size.width / pictureSize.width,
        size.height / pictureSize.height,
      );
      canvas.drawPicture(picture!);
      canvas.restore();
    }

    // Ab hier in Figur-Koordinaten (0..205 × 0..354) arbeiten.
    final scale = size.width / _kFigW;

    if (_kDebugGrid) _paintGrid(canvas, size, scale);

    // 2) Region-Marker auf dieselbe Canvas.
    for (final r in regions) {
      final on = selected.contains(r.label);
      for (final sp in r.spots) {
        final rect = Rect.fromCenter(
          center: Offset(sp.cx * scale, sp.cy * scale),
          width: sp.rx * 2 * scale,
          height: sp.ry * 2 * scale,
        );
        if (on) {
          canvas.drawOval(
            rect,
            Paint()..color = AppColors.sageDeep.withValues(alpha: 0.55),
          );
          canvas.drawOval(
            rect,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = AppColors.sageDeep,
          );
        } else {
          _dashedOval(canvas, rect);
        }
      }
    }
  }

  void _paintGrid(Canvas canvas, Size size, double scale) {
    final thin = Paint()
      ..color = const Color(0x55FF0000)
      ..strokeWidth = 0.5;
    final thick = Paint()
      ..color = const Color(0xAAFF0000)
      ..strokeWidth = 1.0;
    for (int x = 0; x <= 205; x += 10) {
      canvas.drawLine(Offset(x * scale, 0), Offset(x * scale, size.height),
          x % 50 == 0 ? thick : thin);
    }
    for (int y = 0; y <= 354; y += 10) {
      canvas.drawLine(Offset(0, y * scale), Offset(size.width, y * scale),
          y % 50 == 0 ? thick : thin);
    }
  }

  void _dashedOval(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = AppColors.sageDeep.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addOval(rect);
    const dash = 4.0, gap = 3.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FigurePainter old) =>
      old.picture != picture ||
      old.selected != selected ||
      old.regions != regions;
}
