import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import 'wallet_connection_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                  child: const Text('Connect wallet'),
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
    );
  }
}
