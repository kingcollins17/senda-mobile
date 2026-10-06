import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tabIndex = 0; // 0 for Log In, 1 for Sign Up

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(isWalletConnected: true),
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
  }

  Widget _buildSocialButton(String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        onPressed: _navigateToHome,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, bool isPassword) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Email address', false).animate().fade().slideX(begin: 0.05),
        _buildTextField('Password', true).animate().fade(delay: 100.ms).slideX(begin: 0.05),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToHome,
            child: const Text('Create Account'),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        const Center(child: Text('Or continue with', style: TextStyle(color: Colors.white60))).animate().fade(delay: 300.ms),
        const SizedBox(height: 24),
        _buildSocialButton('Google', Icons.g_mobiledata).animate().fade(delay: 400.ms).slideY(begin: 0.1),
        _buildSocialButton('Apple', Icons.apple).animate().fade(delay: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Email address', false).animate().fade().slideX(begin: 0.05),
        _buildTextField('Password', true).animate().fade(delay: 100.ms).slideX(begin: 0.05),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot password?', style: TextStyle(color: Colors.white60)),
          ),
        ).animate().fade(delay: 150.ms),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToHome,
            child: const Text('Log In'),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        const Center(child: Text('Or log in with', style: TextStyle(color: Colors.white60))).animate().fade(delay: 300.ms),
        const SizedBox(height: 24),
        _buildSocialButton('Google', Icons.g_mobiledata).animate().fade(delay: 400.ms).slideY(begin: 0.1),
        _buildSocialButton('Apple', Icons.apple).animate().fade(delay: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1),
              const SizedBox(height: 8),
              const Text(
                'Let\'s get you set up.',
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ).animate().fade(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text('Log In', style: TextStyle(fontWeight: _tabIndex == 0 ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text('Sign Up', style: TextStyle(fontWeight: _tabIndex == 1 ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
              
              const SizedBox(height: 32),
              
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                    fillColor: Colors.transparent,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: _tabIndex == 0 ? _buildLoginForm() : _buildSignUpForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
