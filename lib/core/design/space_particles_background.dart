import 'dart:math';

import 'package:flutter/material.dart';
import 'package:senda/core/design/app_colors.dart';

/// Animated monochrome star field shared by onboarding and splash screens.
class SpaceParticlesBackground extends StatefulWidget {
  const SpaceParticlesBackground({super.key});

  @override
  State<SpaceParticlesBackground> createState() =>
      _SpaceParticlesBackgroundState();
}

class _SpaceParticlesBackgroundState extends State<SpaceParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(
      60,
      (_) => _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 3 + 1.5,
        brightness: random.nextDouble(),
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _ParticlePainter(
          particles: _particles,
          animationValue: _controller.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.brightness,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double brightness;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  final List<_Particle> particles;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      var y = particle.y - animationValue * particle.speed;
      if (y < 0) y += 1;
      if (y > 1) y -= 1;

      var x =
          particle.x +
          sin(animationValue * pi * 8 + particle.y * 10) *
              0.04 *
              particle.speed +
          cos(animationValue * pi * 4 + particle.x * 10) *
              0.03 *
              particle.speed;
      if (x < 0) x += 1;
      if (x > 1) x -= 1;

      final pulse =
          sin(animationValue * pi * 8 + particle.brightness * 10) * 0.5 + 0.5;
      final opacity = ((particle.brightness * 0.4 + 0.1) * pulse + 0.2).clamp(
        0.0,
        1.0,
      );

      final paint = Paint()
        ..color = AppColors.particle.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
