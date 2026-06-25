import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AuthScreenBackground extends StatelessWidget {
  const AuthScreenBackground({
    super.key,
    required this.child,
    this.showDotGrid = false,
  });

  final Widget child;
  final bool showDotGrid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        isDark ? AppColors.primaryLight : AppColors.primary;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F0E12),
                    Color(0xFF17161C),
                    Color(0xFF1F1E25),
                  ],
                  stops: [0.0, 0.45, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3ECFF),
                    Color(0xFFFAF7FF),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
        ),
        child: Stack(
          children: [
            if (showDotGrid)
              Positioned.fill(child: _DotGridPattern(accent: accent)),
            Positioned(
              top: -90,
              right: -70,
              child: _GlowOrb(
                size: 240,
                color: accent.withValues(alpha: isDark ? 0.12 : 0.09),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: _GlowOrb(
                size: 200,
                color: (isDark ? AppColors.accent : AppColors.accent)
                    .withValues(alpha: 0.1),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _DotGridPattern extends StatelessWidget {
  const _DotGridPattern({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter(accent: accent));
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 22.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
