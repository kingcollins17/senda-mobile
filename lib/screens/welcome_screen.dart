import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:senda/core/design/space_particles_background.dart';
import '../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The beautiful space particles background
          const Positioned.fill(child: SpaceParticlesBackground()),

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
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 32,
                          color: Colors.white,
                        ),
                      )
                      .animate()
                      .fade(duration: 500.ms, delay: 100.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 48),
                  Text(
                        'Your crypto.\nYour everyday life.',
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(height: 1.2),
                      )
                      .animate()
                      .fade(duration: 500.ms, delay: 300.ms)
                      .slideY(
                        begin: 0.2,
                        duration: 600.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  const SizedBox(height: 16),
                  Text(
                        'Pay for things using the\ncrypto you already own.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      )
                      .animate()
                      .fade(duration: 500.ms, delay: 500.ms)
                      .slideY(
                        begin: 0.2,
                        duration: 600.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  const Spacer(),

                  ElevatedButton(
                        onPressed: () => context.pushNamed(AppRouteNames.auth),
                        child: const Text('Sign Up / Log In'),
                      )
                      .animate()
                      .fade(duration: 500.ms, delay: 600.ms)
                      .slideY(
                        begin: 0.2,
                        duration: 600.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.goNamed(
                          AppRouteNames.home,
                          queryParameters: {'connected': 'false'},
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white60,
                      ),
                      child: const Text("I'll do this later"),
                    ),
                  ).animate().fade(duration: 500.ms, delay: 900.ms),
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
