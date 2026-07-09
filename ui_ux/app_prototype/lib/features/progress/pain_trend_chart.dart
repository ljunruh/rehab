import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

/// Schmerz-Verlaufsdiagramm (weiche Liniengrafik).
/// Zeigt den Schmerzverlauf einer Region als geglättete Kurve mit
/// Flächenfüllung und Datenpunkten.
class PainTrendChart extends StatelessWidget {
  final List<PainLog> entries;
  final double height;

  const PainTrendChart({
    super.key,
    required this.entries,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('Noch keine Daten', style: AppText.caption)),
      );
    }
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _PainChartPainter(sorted)),
    );
  }
}

class _PainChartPainter extends CustomPainter {
  final List<PainLog> entries;
  _PainChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    const padLeft = 20.0; // Platz für die Y-Achsen-Beschriftung (1–10)
    const padRight = 8.0;
    const padTop = 12.0;
    const padBottom = 22.0;
    final chartW = size.width - padLeft - padRight;
    final chartH = size.height - padTop - padBottom;
    final baseY = padTop + chartH;

    final n = entries.length;
    double xFor(int day) => padLeft + ((day - 1) / 30) * chartW;
    double yFor(int level) =>
        padTop + (1 - (level.clamp(0, 10)) / 10) * chartH;

    // Y-Achsen-Beschriftung: 1, 5, 10 (Schmerzlevel-Skala).
    for (final level in [1, 5, 10]) {
      final tp = TextPainter(
        text: TextSpan(
            text: '$level', style: AppText.micro.copyWith(fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = yFor(level);
      tp.paint(canvas, Offset(padLeft - tp.width - 6, y - tp.height / 2));
    }

    final points = <Offset>[
      for (int i = 0; i < n; i++) Offset(xFor(entries[i].date.day), yFor(entries[i].level)),
    ];

    Path buildSmooth(List<Offset> pts) {
      final path = Path();
      if (pts.isEmpty) return path;
      path.moveTo(pts[0].dx, pts[0].dy);
      const tension = 0.18;
      for (int i = 0; i < pts.length - 1; i++) {
        final p0 = i > 0 ? pts[i - 1] : pts[i];
        final p1 = pts[i];
        final p2 = pts[i + 1];
        final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
        final c1 = Offset(p1.dx + (p2.dx - p0.dx) * tension,
            p1.dy + (p2.dy - p0.dy) * tension);
        final c2 = Offset(p2.dx - (p3.dx - p1.dx) * tension,
            p2.dy - (p3.dy - p1.dy) * tension);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
      }
      return path;
    }

    final linePath = buildSmooth(points);
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, baseY)
      ..lineTo(points.first.dx, baseY)
      ..close();

    final areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x4D2F7E72), Color(0x002F7E72)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.sage;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = AppColors.sage;
    for (final p in points) {
      canvas.drawCircle(p, 3.4, dotPaint);
    }

    for (final day in [1, 10, 20, 31]) {
      final tp = TextPainter(
        text: TextSpan(text: '$day', style: AppText.micro.copyWith(fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (xFor(day) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(_PainChartPainter old) => old.entries != entries;
}
