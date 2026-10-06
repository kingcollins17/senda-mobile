import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import 'wallet_connection_screen.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The beautiful space particles background
          const Positioned.fill(
            child: SpaceParticlesBackground(),
          ),
          
          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.account_balance_wallet, size: 32, color: Colors.white),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 100.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 48),
                  Text(
                    'Your crypto.\nYour everyday life.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      height: 1.2,
                    ),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutQuart),
                  
                  const SizedBox(height: 16),
                  Text(
                    'Pay for things using the\ncrypto you already own.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutQuart),
                  
                  const Spacer(),
                  
                  OpenContainer(
                    closedElevation: 0,
                    closedColor: Colors.transparent,
                    openElevation: 0,
                    openColor: Colors.transparent,
                    middleColor: Colors.transparent,
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: const Duration(milliseconds: 500),
                    closedBuilder: (context, action) => ElevatedButton(
                      onPressed: action,
                      child: const Text('Sign Up / Log In'),
                    ),
                    openBuilder: (context, action) => const AuthScreen(),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutQuart),
                  
                  const SizedBox(height: 16),

                  OpenContainer(
                    closedElevation: 0,
                    closedColor: Colors.transparent,
                    openElevation: 0,
                    openColor: Colors.transparent,
                    middleColor: Colors.transparent,
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: const Duration(milliseconds: 500),
                    closedBuilder: (context, action) => OutlinedButton(
                      onPressed: action,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('Connect external wallet'),
                    ),
                    openBuilder: (context, action) => const WalletConnectionScreen(),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 700.ms)
                  .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutQuart),
                  
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(isWalletConnected: false),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SharedAxisTransition(
                                fillColor: Colors.transparent,
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType: SharedAxisTransitionType.scaled,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white60,
                      ),
                      child: const Text("I'll do this later"),
                    ),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 900.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle Data Class
class Particle {
  double x;
  double y;
  double size;
  double speed;
  double brightness;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.brightness,
  });
}

// Background Widget
class SpaceParticlesBackground extends StatefulWidget {
  const SpaceParticlesBackground({super.key});

  @override
  State<SpaceParticlesBackground> createState() => _SpaceParticlesBackgroundState();
}

class _SpaceParticlesBackgroundState extends State<SpaceParticlesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize 60 particles with random properties
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1, // Size between 1 and 4
        speed: _random.nextDouble() * 3.0 + 1.5, // Faster speed (1.5 to 4.5)
        brightness: _random.nextDouble(),
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(); // Loop continuously
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
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Custom Painter to draw particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Calculate smooth vertical movement (moving upwards)
      double currentY = p.y - (animationValue * p.speed);
      // Wrap around the screen
      if (currentY < 0) currentY += 1.0;
      if (currentY > 1) currentY -= 1.0;

      // Add more dynamic and organic horizontal drift using overlapping waves
      double currentX = p.x + 
          (sin(animationValue * pi * 8 + p.y * 10) * 0.04 * p.speed) + 
          (cos(animationValue * pi * 4 + p.x * 10) * 0.03 * p.speed);
      if (currentX < 0) currentX += 1.0;
      if (currentX > 1) currentX -= 1.0;

      // Twinkle effect: pulsating brightness
      double pulse = sin(animationValue * pi * 8 + p.brightness * 10) * 0.5 + 0.5;
      double opacity = (p.brightness * 0.4 + 0.1) * pulse;

      final actualX = currentX * size.width;
      final actualY = currentY * size.height;

      // Draw outer glowing halo for larger/brighter particles
      if (p.size > 2.5) {
        final glowPaint = Paint()
          ..color = Colors.blueAccent.withValues(alpha: opacity * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
        canvas.drawCircle(Offset(actualX, actualY), p.size * 2.5, glowPaint);
      }

      // Draw the core particle
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity + 0.2);
      canvas.drawCircle(Offset(actualX, actualY), p.size, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
