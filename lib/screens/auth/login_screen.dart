import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

/// Login screen with email/password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accent, Color(0xFF0D1441)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo area ──────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.playerTrail,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    size: 40,
                    color: AppColors.playerTrail,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Territory Run',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Claim the world by running',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white60,
                  ),
                ),
                const Spacer(),

                // ── Email field ────────────────────────────
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 14),

                // ── Password field ─────────────────────────
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    'Password',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white38,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Login button ───────────────────────────
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.playerTrail,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ))
                            : Text(
                                'LOG IN',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                // ── Error ──────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    if (auth.error == null) return const SizedBox(height: 14);
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Social login ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(
                      Icons.g_mobiledata_rounded,
                      'Continue with Google',
                      onTap: () => _handleGoogleLogin(context),
                    ),
                  ],
                ),
                const Spacer(),

                // ── Sign up link ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()),
                      ),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.playerTrail,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.playerTrail, width: 1.5),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      // Navigation happens automatically via AuthProvider observation in app.dart
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }
}
