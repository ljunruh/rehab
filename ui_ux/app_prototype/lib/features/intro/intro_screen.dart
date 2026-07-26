import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

/// Animiertes Intro / Splash beim App-Start.
///
/// Zeigt das ReVia-Logo (assets/logo/logo.svg) „beleuchtet": ein sanft
/// atmender Glow-Halo, aus dem Zentrum ausstrahlende Ripple-Ringe (passend
/// zum radialen Logo-Motiv = Bewegung/Energie) und die eingeblendete
/// Wortmarke. Läuft ~2,7 s und ruft dann [onDone] auf (→ Übergang zur App).
class IntroScreen extends StatefulWidget {
  final VoidCallback onDone;
  const IntroScreen({super.key, required this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro; // einmaliger Ablauf
  late final AnimationController _pulse; // Dauerschleife (Glow + Ripples)

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _logoFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.4, 0.72, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.4, 0.78, curve: Curves.easeOut),
      ),
    );

    _intro.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.12),
          radius: 1.0,
          colors: [Color(0xFF3A8175), AppColors.sageDeep],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _pulse]),
                builder: (context, _) {
                  final t = _pulse.value;
                  final breathe = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ausstrahlende Ringe
                      Opacity(
                        opacity: _logoFade.value,
                        child: CustomPaint(
                          size: const Size(260, 260),
                          painter: _RipplePainter(t),
                        ),
                      ),
                      // Weicher Glow-Halo (atmet)
                      Opacity(
                        opacity: _logoFade.value * (0.45 + 0.35 * breathe),
                        child: Container(
                          width: 160 + 26 * breathe,
                          height: 160 + 26 * breathe,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0x73FFFFFF), Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                      ),
                      // Logo
                      Opacity(
                        opacity: _logoFade.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: SvgPicture.asset(
                            'assets/logo/logo.svg',
                            width: 116,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _intro,
              builder: (context, _) => Opacity(
                opacity: _textFade.value,
                child: Transform.translate(
                  offset: Offset(0, _textSlide.value),
                  child: Text(
                    'ReVia',
                    style: AppText.screenTitle.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _intro,
              builder: (context, _) => Opacity(
                opacity: _textFade.value * 0.85,
                child: Text(
                  'Deine Reha. Dein Tempo.',
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zeichnet mehrere aus dem Zentrum ausstrahlende, ausblendende Ringe.
class _RipplePainter extends CustomPainter {
  final double t; // 0..1, läuft in Schleife
  _RipplePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const rings = 3;
    for (int i = 0; i < rings; i++) {
      final phase = (t + i / rings) % 1.0;
      final radius = 50 + phase * 78; // 50 → 128
      final opacity = (1.0 - phase) * 0.5;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFBCDFD7).withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => oldDelegate.t != t;
}
