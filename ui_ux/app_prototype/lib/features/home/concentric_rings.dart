import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

/// Konzentrische Wochen-Fortschrittsringe (Home-Screen).
///
/// Zeigt pro aktivem Plan einen Ring in der Plan-Farbe. Die Ringe füllen
/// sich beim Erscheinen animiert (Expo-Out-Kurve, gestaffelt). Entspricht
/// ConcentricRings / WeeklyRingArc im JSX-Prototyp.
class ConcentricRings extends StatefulWidget {
  final List<WeeklyRing> rings;
  final double size;
  final double? strokeWidth; // optional für manuelle Überschreibung
  final double? gap;         // optional für manuelle Überschreibung

  const ConcentricRings({
    super.key,
    required this.rings,
    this.size = 168,
    this.strokeWidth,
    this.gap,
  });

  @override
  State<ConcentricRings> createState() => _ConcentricRingsState();
}

class _ConcentricRingsState extends State<ConcentricRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = CurvedAnimation(parent: _controller, curve: AppMotion.expoOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return CustomPaint(
            painter: _RingsPainter(
              rings: widget.rings,
              size: widget.size,
              overrideStrokeWidth: widget.strokeWidth,
              overrideGap: widget.gap,
              t: _anim.value,
            ),
          );
        },
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final List<WeeklyRing> rings;
  final double size;
  final double? overrideStrokeWidth;
  final double? overrideGap;
  final double t; // Animationsfortschritt 0..1

  _RingsPainter({
    required this.rings,
    required this.size,
    this.overrideStrokeWidth,
    this.overrideGap,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rings.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final count = rings.length;

    // Dynamische Berechnung von Ringdicke und Lücke,
    // damit egal wie viele Pläne vorhanden sind, alle Ringe passen.
    final double strokeWidth = overrideStrokeWidth ??
        (count <= 3
            ? 13.0
            : (size.width / (count * 3.2)).clamp(6.0, 12.0));

    final double gap = overrideGap ?? (strokeWidth * 0.35).clamp(2.0, 5.0);

    final outerRadius = size.width / 2 - strokeWidth / 2;

    for (int i = 0; i < count; i++) {
      final ring = rings[i];
      final radius = outerRadius - i * (strokeWidth + gap);

      // Falls es bei extremer Anzahl zu eng wird
      if (radius < strokeWidth / 2) break;

      // Hintergrund-Ring (beige)
      final bgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = AppColors.beige;
      canvas.drawCircle(center, radius, bgPaint);

      // Gestaffelter Start je Ring
      final delayStep = count > 1 ? 0.4 / count : 0.0;
      final delayed = ((t - i * delayStep) / (1 - i * delayStep)).clamp(0.0, 1.0);
      final sweep = 2 * math.pi * ring.progress * delayed;
      if (sweep <= 0) continue;

      final fgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = ring.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start oben
        sweep,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.t != t || old.rings != rings;
}

/// Legende neben den Ringen: ein farbiger Punkt + Label + "done/goal".
class RingsLegend extends StatelessWidget {
  final List<WeeklyRing> rings;
  const RingsLegend({super.key, required this.rings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final r in rings)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: r.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(r.label, style: AppText.body)),
                const SizedBox(width: AppSpacing.base),
                Text(
                  '${r.done}/${r.goal}',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
