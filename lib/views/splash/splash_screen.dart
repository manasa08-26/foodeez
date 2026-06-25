import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/partner_logo.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/auth_screen_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _progressCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
    );
    _bottomFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _orbitCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final accent = colors.primaryColor;

    return Scaffold(
      backgroundColor: colors.background,
      body: AuthScreenBackground(
        showDotGrid: true,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: FadeTransition(
                  opacity: _textFade,
                  child: const _PartnerPortalBadge(),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _orbitCtrl,
                                    builder: (_, __) => CustomPaint(
                                      size: const Size(140, 140),
                                      painter: _OrbitRingsPainter(
                                        rotation:
                                            _orbitCtrl.value * 2 * math.pi,
                                        accent: accent,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 76,
                                    height: 76,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colors.primarySurface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.14),
                                          blurRadius: 30,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: const PartnerLogo.splash(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'FooDeeZ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: accent,
                                    letterSpacing: -1,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'RESTAURANT PARTNER PORTAL',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accent.withValues(alpha: 0.62),
                                    letterSpacing: 2.8,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textPrimary,
                                      letterSpacing: -0.6,
                                      height: 1.1,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Tap. '),
                                      TextSpan(
                                        text: 'Eat.',
                                        style: TextStyle(color: accent),
                                      ),
                                      const TextSpan(text: ' Repeat.'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Order in seconds · Delivered fast',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _bottomFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 4,
                        child: AnimatedBuilder(
                          animation: _progressCtrl,
                          builder: (_, __) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: Stack(
                                children: [
                                  Container(
                                    color: accent.withValues(alpha: 0.12),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor:
                                        0.35 + (_progressCtrl.value * 0.55),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: colors.primaryGradient,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'READY TO SERVE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accent.withValues(alpha: 0.7),
                          letterSpacing: 2.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FeatureChip(label: '👇 Tap to order'),
                            _FeatureChip(label: '🍔 Your favourites'),
                            _FeatureChip(label: '🛵 Fast delivery'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerPortalBadge extends StatelessWidget {
  const _PartnerPortalBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final accent = colors.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primarySurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'PARTNER PORTAL',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: accent,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final accent = colors.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  _OrbitRingsPainter({required this.rotation, required this.accent});

  final double rotation;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringPaint = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final radius in [58.0, 66.0]) {
      _drawDashedCircle(canvas, center, radius, ringPaint);
    }

    final dotPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final radii = [70.0, 80.0, 75.0];
    for (var i = 0; i < radii.length; i++) {
      final angle = rotation + (i * 2 * math.pi / 3);
      final r = radii[i];
      final dot = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawCircle(dot, i == 1 ? 5 : 4, dotPaint);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const dash = 5.0;
    const gap = 7.0;
    final circumference = 2 * math.pi * radius;
    final count = circumference / (dash + gap);
    for (var i = 0; i < count; i++) {
      final start = (i * (dash + gap)) / radius;
      final sweep = dash / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.accent != accent;
}
