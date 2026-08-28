import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/enum/joint.dart';

/// Interaktive Körper-Region-Auswahl (Vorderseite / Rückseite).
///
/// Schematische Figur nach Sophias Design (Screen-Recording 06.07.26):
/// antippbare Regionen werden bei Auswahl [AppColors.sageDeep] gefüllt,
/// sonst gestrichelt umrandet. Vorder-/Rückseite umschaltbar.
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

/// Ein Positions-Rechteck einer antippbaren Region (relativ zur 240×420-Figur).
/// [r] = Eckenradius (großer Wert ⇒ Oval/Kreis).
class _Part {
  final double l, t, w, h, r;
  const _Part(this.l, this.t, this.w, this.h, this.r);
}

class _Region {
  final String label;
  final bool back; // true = nur auf Rückseite sichtbar
  final List<_Part> parts;
  const _Region(this.label, {this.back = false, required this.parts});
}

/// Regionen + Positionen (nimmt joints label de)
/// TODO richtig mappen sobald der richtige körper kommt
const List<_Region> _kRegions = [
  // ── Vorderseite ──
  _Region('Halswirbelsäule', parts: [_Part(106, 70, 28, 15, 8)]),
  _Region('Schultergelenk', parts: [_Part(66, 90, 32, 28, 14), _Part(142, 90, 32, 28, 14)]),
  _Region('Ellbogengelenk', parts: [_Part(52, 140, 24, 24, 12), _Part(164, 140, 24, 24, 12)]),
  _Region('Obere rückengelenke', parts: [_Part(92, 128, 56, 40, 18)]),
  _Region('Hüftgelenk', parts: [_Part(90, 216, 60, 34, 18)]),
  _Region('Handgelenk', parts: [_Part(52, 196, 24, 24, 12), _Part(164, 196, 24, 24, 12)]),
  _Region('Kniegelenk', parts: [_Part(92, 300, 28, 28, 14), _Part(120, 300, 28, 28, 14)]),
  _Region('Sprunggelenk', parts: [_Part(94, 360, 24, 18, 9), _Part(122, 360, 24, 18, 9)]),

  // ── Rückseite ──
  _Region('Halswirbelsäule', back: true, parts: [_Part(106, 70, 28, 15, 8)]),
  _Region('Schultergelenk', back: true, parts: [_Part(66, 90, 32, 28, 14), _Part(142, 90, 32, 28, 14)]),
  _Region('Ellbogengelenk', back: true, parts: [_Part(52, 140, 24, 24, 12), _Part(164, 140, 24, 24, 12)]),
  _Region('Obere rückengelenke', back: true, parts: [_Part(92, 128, 56, 40, 18)]),
  _Region('Wirbelsäulengelenke', back: true, parts: [_Part(112, 92, 16, 128, 8)]),
  _Region('Untere Rückengelenke', back: true, parts: [_Part(90, 216, 60, 34, 18)]),
  _Region('Handgelenk', back: true, parts: [_Part(52, 196, 24, 24, 12), _Part(164, 196, 24, 24, 12)]),
  _Region('Sprunggelenk', back: true, parts: [_Part(94, 360, 24, 18, 9), _Part(122, 360, 24, 18, 9)]),
];

class _BodyMapSelectorState extends State<BodyMapSelector> {
  bool _back = false;

  void _toggle(String label) {
    final next = List<String>.from(widget.selected);
    next.contains(label) ? next.remove(label) : next.add(label);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final regions = _kRegions.where((r) => r.back == _back).toList();

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
        SizedBox(
          width: 240,
          height: 446,
          child: Stack(
            children: [
              Positioned.fill(child: _Silhouette(showFace: !_back)),
              for (final r in regions)
                for (final p in r.parts)
                  Positioned(
                    left: p.l,
                    top: p.t,
                    width: p.w,
                    height: p.h,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggle(r.label),
                      child: _RegionShape(
                        selected: widget.selected.contains(r.label),
                        radius: p.r,
                      ),
                    ),
                  ),
            ],
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

/// Gefüllte (ausgewählt) bzw. gestrichelt umrandete (nicht gewählt) Region.
class _RegionShape extends StatelessWidget {
  final bool selected;
  final double radius;
  const _RegionShape({required this.selected, required this.radius});

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.sageDeep,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }
    return CustomPaint(painter: _DashedRRectPainter(radius));
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius;
  _DashedRRectPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sageDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rr = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rr);
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
  bool shouldRepaint(covariant _DashedRRectPainter old) => old.radius != radius;
}

/// Helle, nicht interaktive Körper-Silhouette mit Kopf-Smiley.
class _Silhouette extends StatelessWidget {
  final bool showFace;
  const _Silhouette({this.showFace = true});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SilhouettePainter(showFace));
}

class _SilhouettePainter extends CustomPainter {
  final bool showFace;
  _SilhouettePainter(this.showFace);

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()
      ..color = const Color(0x99D2E7E1) // sageLight ~60%
      ..style = PaintingStyle.fill;

    RRect rr(double l, double t, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(l, t, w, h), Radius.circular(r));

    // Kopf
    const head = Offset(120, 40);
    canvas.drawCircle(head, 26, body);
    // Torso (Schulter bis Hüfte)
    canvas.drawRRect(rr(90, 84, 60, 138, 24), body);
    // Arme
    canvas.drawRRect(rr(60, 92, 18, 122, 9), body);
    canvas.drawRRect(rr(162, 92, 18, 122, 9), body);
    // Beine
    canvas.drawRRect(rr(96, 224, 20, 156, 10), body);
    canvas.drawRRect(rr(124, 224, 20, 156, 10), body);

    // Smiley – nur auf der Vorderseite
    if (showFace) {
      final face = Paint()
        ..color = const Color(0xB31F4E47) // sageDeep ~70%
        ..style = PaintingStyle.fill;
      canvas.drawCircle(head + const Offset(-8, -3), 2.2, face);
      canvas.drawCircle(head + const Offset(8, -3), 2.2, face);
      final smile = Paint()
        ..color = const Color(0xB31F4E47)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: head + const Offset(0, 2), width: 18, height: 14),
        0.15 * math.pi,
        0.7 * math.pi,
        false,
        smile,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter old) => old.showFace != showFace;
}