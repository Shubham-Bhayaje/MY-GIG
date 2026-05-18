import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../widgets/glass_card.dart';
import '../services/notification_service.dart';
import 'main_shell.dart';
import 'selfie_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF050505),
                  AppColors.primaryDark,
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),

          // Decorative glow
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(
                    10 * _floatController.value,
                    -5 * _floatController.value,
                  ),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentCyan.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 150,
            left: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(
                    -8 * _floatController.value,
                    8 * _floatController.value,
                  ),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentPurple.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentCyan,
                                AppColors.accentPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentCyan.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'GigMap',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin
                              ? 'Welcome back! Sign in to continue'
                              : 'Create an account to get started',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.9, 0.9),
                        duration: 500.ms,
                      ),
                  const SizedBox(height: 36),

                  // Toggle tabs
                  GlassCard(
                    padding: const EdgeInsets.all(4),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabButton('Sign In', _isLogin, () {
                            setState(() => _isLogin = true);
                          }),
                        ),
                        Expanded(
                          child: _buildTabButton('Sign Up', !_isLogin, () {
                            setState(() => _isLogin = false);
                          }),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name (sign up only)
                        if (!_isLogin) ...[
                          _buildInputField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                v?.isEmpty == true ? 'Name is required' : null,
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Email is required';
                            if (!v!.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: 16),

                        // Phone (sign up only)
                        if (!_isLogin) ...[
                          _buildInputField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: '+91 XXXXX XXXXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v?.isEmpty == true ? 'Phone is required' : null,
                          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                          const SizedBox(height: 16),
                        ],

                        // Password
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (v) {
                            if (v?.isEmpty == true) {
                              return 'Password is required';
                            }
                            if (v!.length < 6) {
                              return 'Min 6 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                        if (_isLogin) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentCyan,
                              foregroundColor: AppColors.primaryDark,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 8,
                              shadowColor:
                                  AppColors.accentCyan.withValues(alpha: 0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryDark,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppColors.divider, thickness: 0.5)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppColors.divider, thickness: 0.5)),
                          ],
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Social login buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                  Icons.g_mobiledata_rounded, 'Google'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSocialButton(
                                  Icons.phone_android_rounded, 'Phone OTP'),
                            ),
                          ],
                        ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                        const SizedBox(height: 30),

                        // Switch mode text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? "Don't have an account? "
                                  : 'Already have an account? ',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _isLogin = !_isLogin);
                              },
                              child: Text(
                                _isLogin ? 'Sign Up' : 'Sign In',
                                style: const TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentCyan.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.3),
                  width: 0.5)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.accentCyan : AppColors.textMuted,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: 12,
      onTap: () => _handleSocialLogin(label),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    String? error;

    if (_isLogin) {
      // Sign In
      debugPrint('[AUTH] Signing in...');
      error = await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('[AUTH] Sign in result: ${error ?? "SUCCESS"}');
    } else {
      // Sign Up
      debugPrint('[AUTH] Signing up...');
      error = await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      debugPrint('[AUTH] Sign up result: ${error ?? "SUCCESS"}');

      // Save user profile to Firestore (non-blocking)
      if (error == null && authService.currentUser != null) {
        try {
          final db = DatabaseService();
          db.createUserProfile(UserProfile(
            id: authService.uid!,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            role: UserRole.both,
            rating: 0,
            completedJobs: 0,
            totalReviews: 0,
            skills: [],
            isVerified: false,
            walletBalance: 0,
            latitude: 19.2183,
            longitude: 72.9781,
            joinedAt: DateTime.now(),
          ));
          debugPrint('[AUTH] Firestore profile save triggered');
        } catch (e) {
          debugPrint('[AUTH] Firestore error (non-fatal): $e');
        }
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      // Sync with AppState
      final appState = context.read<AppState>();
      appState.login(
        name: authService.currentUser?.displayName ?? _nameController.text,
        email: authService.currentUser?.email ?? _emailController.text,
        phone: _phoneController.text,
        uid: authService.uid,
      );

      // Initialize FCM for the logged-in user
      if (authService.uid != null) {
        NotificationService().init(authService.uid!);
        NotificationService().subscribeToTopic('new_gigs');
      }

      if (_isLogin) {
        // Existing user → go straight to app
        _navigateToApp();
      } else {
        // New user → mandatory selfie verification first
        _navigateToSelfieVerification(
          uid: authService.uid!,
          name: _nameController.text.trim(),
        );
      }
    }
  }

  void _handleSocialLogin(String provider) {
    if (provider == 'Phone OTP') {
      _showPhoneOTPSheet();
    }
    // Google Sign-In can be added later with google_sign_in package
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter your email first, then tap Forgot Password.');
      return;
    }
    final authService = context.read<AuthService>();
    final error = await authService.sendPasswordReset(email);
    if (!mounted) return;
    if (error != null) {
      _showError(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.accentGreen),
              SizedBox(width: 8),
              Expanded(child: Text('Password reset email sent! Check your inbox.')),
            ],
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showPhoneOTPSheet() {
    final phoneCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    String? verificationId;
    bool otpSent = false;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone OTP Login',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!otpSent) ...[
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: '+91 XXXXX XXXXX',
                        prefixIcon: Icon(Icons.phone, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : () async {
                          if (phoneCtrl.text.trim().isEmpty) return;
                          setSheetState(() => loading = true);
                          final authService = context.read<AuthService>();
                          await authService.sendOTP(
                            phoneNumber: phoneCtrl.text.trim(),
                            onCodeSent: (vId) {
                              setSheetState(() {
                                verificationId = vId;
                                otpSent = true;
                                loading = false;
                              });
                            },
                            onError: (err) {
                              setSheetState(() => loading = false);
                              Navigator.pop(ctx);
                              _showError(err);
                            },
                            onAutoVerify: (credential) async {
                              await context.read<AuthService>()
                                  .auth.signInWithCredential(credential);
                              if (mounted) {
                                context.read<AppState>().login();
                                Navigator.pop(ctx);
                                _navigateToApp();
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Send OTP',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'OTP sent to ${phoneCtrl.text}',
                      style: TextStyle(color: AppColors.accentGreen, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 24, letterSpacing: 8),
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: '------',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : () async {
                          if (otpCtrl.text.length != 6) return;
                          setSheetState(() => loading = true);
                          final authService = context.read<AuthService>();
                          final error = await authService.verifyOTP(
                            verificationId: verificationId!,
                            otp: otpCtrl.text,
                          );
                          setSheetState(() => loading = false);
                          if (error != null) {
                            _showError(error);
                          } else {
                            if (mounted) {
                              context.read<AppState>().login();
                              Navigator.pop(ctx);
                              _navigateToApp();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Verify & Login',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _navigateToSelfieVerification({required String uid, required String name}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => SelfieVerificationScreen(
          uid: uid,
          userName: name,
          onVerified: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }
}
