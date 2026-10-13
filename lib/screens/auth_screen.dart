import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senda/core/app_strings.dart';
import 'package:senda/core/providers/auth_provider.dart';
import 'package:senda/core/util/context_util.dart';
import '../routes/app_routes.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  int _tabIndex = 0; // 0 for Log In, 1 for Sign Up

  bool _isLoggingIn = false;
  bool _isRegistering = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  bool _validateForm() => _formKey.currentState?.validate() ?? false;

  void _handleLogin() {
    if (_isLoggingIn || !_validateForm()) return;
    setState(() {
      _isLoggingIn = true;
    });

    ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          onSuccess: _onAuthSuccess,
          onError: _onAuthError,
        );
  }

  void _handleRegister() {
    if (_isRegistering || !_validateForm()) return;
    setState(() {
      _isRegistering = true;
    });

    ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullname: _fullNameController.text.trim(),
          onSuccess: _onAuthSuccess,
          onError: _onAuthError,
        );
  }

  void _onAuthSuccess() {
    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
      _isRegistering = false;
    });
    context.goNamed(AppRouteNames.home);
  }

  void _onAuthError(Object error) {
    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
      _isRegistering = false;
    });
    context.showToast(error.toString());
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.emailRequired;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 8) return AppStrings.passwordTooShort;
    return null;
  }

  void _setTab(int tabIndex) {
    if (_tabIndex == tabIndex) return;
    setState(() => _tabIndex = tabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _formKey.currentState?.reset();
    });
  }

  Widget _buildSocialButton(String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required bool isPassword,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          suffixIcon: isPassword
              ? IconButton(
                  tooltip: _isPasswordVisible
                      ? AppStrings.hidePassword
                      : AppStrings.showPassword,
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white60,
                  ),
                )
              : null,
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
        _buildTextField(
          hint: 'Full name',
          controller: _fullNameController,
          isPassword: false,
          textCapitalization: TextCapitalization.words,
          validator: (value) => value == null || value.trim().isEmpty
              ? AppStrings.fullNameRequired
              : null,
        ).animate().fade().slideX(begin: 0.05),
        _buildTextField(
          hint: 'Email address',
          controller: _emailController,
          isPassword: false,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ).animate().fade(delay: 100.ms).slideX(begin: 0.05),
        _buildTextField(
          hint: 'Password',
          controller: _passwordController,
          isPassword: true,
          validator: _validatePassword,
        ).animate().fade(delay: 200.ms).slideX(begin: 0.05),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isRegistering ? null : _handleRegister,
            child: Text(
              _isRegistering ? 'Creating account...' : 'Create Account',
            ),
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.white60),
          ),
        ).animate().fade(delay: 400.ms),
        const SizedBox(height: 24),
        _buildSocialButton(
          'Google',
          Icons.g_mobiledata,
        ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
        _buildSocialButton(
          'Apple',
          Icons.apple,
        ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          hint: 'Email address',
          controller: _emailController,
          isPassword: false,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ).animate().fade().slideX(begin: 0.05),
        _buildTextField(
          hint: 'Password',
          controller: _passwordController,
          isPassword: true,
          validator: _validatePassword,
        ).animate().fade(delay: 100.ms).slideX(begin: 0.05),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot password?',
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ).animate().fade(delay: 150.ms),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoggingIn ? null : _handleLogin,
            child: Text(_isLoggingIn ? 'Getting you in...' : 'Log In'),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Or log in with',
            style: TextStyle(color: Colors.white60),
          ),
        ).animate().fade(delay: 300.ms),
        const SizedBox(height: 24),
        _buildSocialButton(
          'Google',
          Icons.g_mobiledata,
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
        _buildSocialButton(
          'Apple',
          Icons.apple,
        ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
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
                            onTap: () => _setTab(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tabIndex == 0
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  fontWeight: _tabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _setTab(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tabIndex == 1
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontWeight: _tabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fade(delay: 200.ms)
                  .scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: PageTransitionSwitcher(
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
                  child: _tabIndex == 0
                      ? _buildLoginForm()
                      : _buildSignUpForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
