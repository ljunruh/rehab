import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/enum/joint.dart';

/// Interaktive Körper-Region-Auswahl (Vorderseite / Rückseite).
///
/// Zeichnet eine anatomische Muskelfigur (SVG, in Sage-Grün eingefärbt) und die
/// antippbaren Gelenk-Regionen in **einer einzigen Zeichenebene** ([CustomPaint]):
/// Die SVG wird als [ui.Picture] geladen und zusammen mit den Region-Markern auf
/// dieselbe Canvas gemalt. So können Figur und Marker prinzipiell nicht
/// gegeneinander verrutschen (kein Layer-Drift beim Scrollen).
///
/// Ausgewählte Regionen werden grün gefüllt, nicht gewählte gestrichelt
/// umrandet. Vorder-/Rückseite umschaltbar.
///
/// Regionen entsprechen den `Joint`-Werten (siehe joint.dart). Trefferzonen
/// sind gegen die SVG-Figur kalibriert, aber nicht pixelgenau abgestimmt —
/// vor Release nochmal visuell gegenchecken (ggf. `_kDebugGrid = true` setzen).
///
/// Grafik: „Muscles front and back" von Tomáš Kebert & umimeto.org (nach
/// OpenStax), CC BY-SA 4.0 – umgefärbt. Quelle/Lizenz siehe Impressum.
///
/// [selected]/[onChanged] arbeiten mit den deutschen Joint-Labels
/// (kompatibel zu `user.joints`).
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

// Auf der Figur antippbare Gelenk-Regionen (Joint.labelDE, kompatibel zum KG).
// Vorder-/Rückseiten-Zuordnung entspricht der bisherigen Schema-Figur
// (siehe git-history body_map_selector.dart): Hüfte/Knie nur vorne,
// Wirbelsäule/unterer Rücken nur hinten, Rest auf beiden Seiten sichtbar.
const List<_Reg> _kFront = [
  _Reg('Halswirbelsäule', [_Spot(101, 68, 7, 5)]),
  _Reg('Schultergelenk', [_Spot(68, 94, 11, 10), _Spot(135, 94, 11, 10)]),
  _Reg('Ellbogengelenk', [_Spot(40, 143, 7, 8), _Spot(162, 143, 7, 8)]),
  _Reg('Hüftgelenk', [_Spot(101, 160, 16, 9)]),
  _Reg('Handgelenk', [_Spot(29, 188, 8, 8), _Spot(173, 188, 8, 8)]),
  _Reg('Kniegelenk', [_Spot(86, 248, 8, 9), _Spot(117, 248, 8, 9)]),
  _Reg('Sprunggelenk', [_Spot(88, 313, 6, 6), _Spot(116, 313, 6, 6)]),
];

const List<_Reg> _kBack = [
  _Reg('Halswirbelsäule', [_Spot(102.5, 60, 7, 4.5)]),
  _Reg('Schultergelenk', [_Spot(61.5, 88, 9, 7.5), _Spot(141.5, 88, 9, 7.5)]),
  _Reg('Ellbogengelenk', [_Spot(56.5, 138, 7, 8), _Spot(146.5, 138, 7, 8)]),
  _Reg('Obere rückengelenke', [_Spot(102.5, 102, 13.5, 7)]),
  _Reg('Wirbelsäulengelenke', [_Spot(102.5, 135, 12.5, 7)]),
  _Reg('Untere Rückengelenke', [_Spot(102.5, 158, 13.5, 6.5)]),
  _Reg('Handgelenk', [_Spot(33.5, 186, 8, 8), _Spot(169.5, 186, 8, 8)]),
  // Kniegelenk ist auch von hinten (Kniekehle) auswählbar – war bisher nur
  // auf der Vorderseite antippbar.
  _Reg('Kniegelenk', [_Spot(88, 237, 8, 9), _Spot(117, 237, 8, 9)]),
  _Reg('Sprunggelenk', [_Spot(91.5, 332, 5.5, 5.5), _Spot(113.5, 332, 5.5, 5.5)]),
];

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

        // ── Figur ──
        AspectRatio(
          aspectRatio: _kFigW / _kFigH,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final pic = _back ? _backPic : _frontPic;
              final picSize = _back ? _backSize : _frontSize;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _handleTap(d.localPosition, w, h),
                child: CustomPaint(
                  size: Size(w, h),
                  painter: pic == null
                      ? null
                      : _FigurePainter(
                          picture: pic,
                          pictureSize: picSize,
                          regions: _regs,
                          selected: widget.selected,
                          debugGrid: _kDebugGrid,
                        ),
                  child: pic == null
                      ? const Center(child: CircularProgressIndicator())
                      : null,
                ),
              );
            },
          ),
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
              for (final s in widget.selected)
                AppTag(
                  JointExt.fromString(
                    Joint.values.firstWhere(
                          (e) => e.labelDE == s,
                      orElse: () => Joint.none,
                    ).labelEN,
                  ).labelDE,
                  variant: TagVariant.goal,
                ),
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

/// Malt SVG-Figur + Region-Marker in einem Durchgang auf dieselbe Canvas.
class _FigurePainter extends CustomPainter {
  final ui.Picture picture;
  final Size pictureSize;
  final List<_Reg> regions;
  final List<String> selected;
  final bool debugGrid;

  _FigurePainter({
    required this.picture,
    required this.pictureSize,
    required this.regions,
    required this.selected,
    required this.debugGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _kFigW;
    final scaleY = size.height / _kFigH;

    canvas.save();
    // SVG ist in Figur-Koordinaten (viewBox), auf Ziel-Größe skalieren.
    final svgScaleX = size.width / pictureSize.width;
    final svgScaleY = size.height / pictureSize.height;
    canvas.scale(svgScaleX, svgScaleY);
    canvas.drawPicture(picture);
    canvas.restore();

    for (final r in regions) {
      final isSelected = selected.contains(r.label);
      for (final s in r.spots) {
        final center = Offset(s.cx * scaleX, s.cy * scaleY);
        final radius = Radius.elliptical(s.rx * scaleX, s.ry * scaleY);
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: radius.x * 2,
            height: radius.y * 2,
          ),
          radius,
        );
        if (isSelected) {
          canvas.drawRRect(
            rect,
            Paint()
              ..color = AppColors.sageDeep.withValues(alpha: 0.75)
              ..style = PaintingStyle.fill,
          );
        } else {
          _drawDashedOval(canvas, rect);
        }
      }
    }

    if (debugGrid) {
      final gridPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..strokeWidth = 0.5;
      for (double x = 0; x <= _kFigW; x += 10) {
        canvas.drawLine(Offset(x * scaleX, 0), Offset(x * scaleX, size.height), gridPaint);
      }
      for (double y = 0; y <= _kFigH; y += 10) {
        canvas.drawLine(Offset(0, y * scaleY), Offset(size.width, y * scaleY), gridPaint);
      }
    }
  }

  void _drawDashedOval(Canvas canvas, RRect rect) {
    final paint = Paint()
      ..color = AppColors.sageDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(rect);
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
      old.selected.length != selected.length ||
      !_listEquals(old.selected, selected);

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
