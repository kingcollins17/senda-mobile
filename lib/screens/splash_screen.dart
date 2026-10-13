import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:senda/core/app_strings.dart';
import 'package:senda/core/design/app_colors.dart';
import 'package:senda/core/design/space_particles_background.dart';
import 'package:senda/core/models/storage_keys.dart';
import 'package:senda/core/providers/app_storage_provider.dart';
import 'package:senda/core/util/log_util.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Simulated splash delay for asset loading / token checks
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      final token = appStorage?.get(AppStorageKey.authToken);
      (token as String?)?.debugLog();
      final isAuthenticated = token != null && token.isNotEmpty;
      context.goNamed(
        isAuthenticated ? AppRouteNames.home : AppRouteNames.welcome,
      ); // Or your intended initial route
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          // Particle Field
          const Positioned.fill(child: SpaceParticlesBackground()),

          // Original orbit graphic, with the Senda name and updated tagline.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scale(
                              begin: const Offset(0.92, 0.92),
                              end: const Offset(1.08, 1.08),
                              duration: 2200.ms,
                              curve: Curves.easeInOut,
                            ),
                        CustomPaint(
                              size: const Size(116, 116),
                              painter: _TechOrbitPainter(),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .rotate(duration: 12.seconds),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.emblemHighlight.withValues(
                                  alpha: 0.42,
                                ),
                                AppColors.emblemMidtone.withValues(alpha: 0.65),
                                AppColors.emblemShadow.withValues(alpha: 0.82),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.04),
                                blurRadius: 28,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.currency_exchange_rounded,
                              size: 44,
                              color: AppColors.softWhite,
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fade(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 36),
                Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 350.ms)
                    .slideY(
                      begin: 0.25,
                      duration: 600.ms,
                      curve: Curves.easeOutQuart,
                    ),
                const SizedBox(height: 8),
                Text(
                      'Your wallet for everyday payments',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.62),
                        letterSpacing: 0.3,
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 550.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutQuart,
                    ),
              ],
            ),
          ),

          // Subtle Bottom Status Loader
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 2,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.loader),
                ),
              ),
            ).animate().fade(duration: 500.ms, delay: 900.ms),
          ),
        ],
      ),
    );
  }
}

class _TechOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.orbit.withValues(alpha: 0.18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const arcCount = 4;
    const sweep = (pi * 2) / arcCount;
    for (int i = 0; i < arcCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep * 0.55,
        false,
        paint,
      );
    }

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.38);
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 2, dotPaint);
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
