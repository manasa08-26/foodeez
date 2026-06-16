import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.75, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    // Navigate once auth state is known (not loading)
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitAndNavigate());
  }

  Future<void> _waitAndNavigate() async {
    // Minimum splash time so the animation is visible
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isLoading) {
      // Wait a bit more if still loading
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
    }

    final isAuth = ref.read(authProvider).isAuthenticated;
    if (mounted) {
      context.go(isAuth ? '/dashboard' : '/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F0B3A), Color(0xFF4C2D8F), Color(0xFF6C3FC5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Logo with fade + scale animation
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140,
                  height: 140,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // App name
            FadeTransition(
              opacity: _fade,
              child: const Text(
                'Foodeez',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeTransition(
              opacity: _fade,
              child: const Text(
                'Restaurant Admin',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Loading dots
            FadeTransition(
              opacity: _fade,
              child: const _PulsingDots(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          // Stagger each dot by 0.33 of the animation cycle
          final offset = (i / 3.0);
          final phase = (_ctrl.value + offset) % 1.0;
          final opacity = (phase < 0.5 ? phase * 2 : (1.0 - phase) * 2)
              .clamp(0.25, 1.0)
              .toDouble();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
