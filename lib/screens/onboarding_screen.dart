import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Deep dark background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.3),
                radius: 1.2,
                colors: [
                  Color(0xFF111118),
                  Color(0xFF0A0A0E),
                  Color(0xFF050508),
                ],
              ),
            ),
          ),

          // Animated constellation/network background
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConstellationPainter(
              animation: _driftController,
            ),
          ),

          // Subtle radial glow behind the map area
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentCyan.withValues(
                          alpha: 0.06 + 0.02 * _pulseController.value,
                        ),
                        AppColors.accentPurple.withValues(
                          alpha: 0.03 + 0.01 * _pulseController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Top bar: Logo + GigMap branding
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFF44B8B0)],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Gig',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            TextSpan(
                              text: 'Map',
                              style: TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Premium badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentCyan.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: AppColors.accentCyan.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Beta',
                              style: TextStyle(
                                color: AppColors.accentCyan.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),

                  // Central hero area
                  const Spacer(flex: 3),

                  // Animated map globe illustration
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -6 * _pulseController.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentCyan.withValues(alpha: 0.12),
                            AppColors.accentCyan.withValues(alpha: 0.04),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.accentCyan.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accentCyan.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                          ),
                          // Inner icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentCyan.withValues(alpha: 0.2),
                                  AppColors.accentPurple.withValues(alpha: 0.15),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.accentCyan.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.public_rounded,
                              color: AppColors.accentCyan,
                              size: 30,
                            ),
                          ),
                          // Floating dots
                          Positioned(
                            top: 18,
                            right: 22,
                            child: _buildDot(6, AppColors.accentCyan.withValues(alpha: 0.6)),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 16,
                            child: _buildDot(4, AppColors.accentPurple.withValues(alpha: 0.5)),
                          ),
                          Positioned(
                            top: 40,
                            left: 14,
                            child: _buildDot(5, AppColors.accentGreen.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),

                  const SizedBox(height: 40),

                  // Title: "GigMap: Find local help in minutes."
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: 'GigMap: Find local help in '),
                        TextSpan(
                          text: 'minutes',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.accentCyan,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.15, duration: 600.ms),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    'A map-based micro-job\nmarketplace for your\nneighbourhood.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ).animate()
                      .fadeIn(delay: 550.ms, duration: 600.ms)
                      .slideY(begin: 0.1, duration: 600.ms),

                  const Spacer(flex: 2),

                  // "Get Started" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentCyan,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms)
                      .slideY(begin: 0.2, duration: 500.ms),

                  const SizedBox(height: 16),

                  // "Already have an account? Log In"
                  TextButton(
                    onPressed: _goToApp,
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              color: AppColors.accentCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 850.ms, duration: 500.ms),

                  const SizedBox(height: 20),

                  // Footer dots (page indicator style — decorative)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(true),
                      const SizedBox(width: 6),
                      _buildIndicator(false),
                      const SizedBox(width: 6),
                      _buildIndicator(false),
                    ],
                  ).animate().fadeIn(delay: 900.ms, duration: 400.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active ? AppColors.accentCyan : AppColors.textMuted.withValues(alpha: 0.25),
      ),
    );
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

/// Draws a subtle animated constellation/network pattern in the background.
class _ConstellationPainter extends CustomPainter {
  final Animation<double> animation;

  _ConstellationPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    const nodeCount = 30;
    final nodes = <Offset>[];

    for (int i = 0; i < nodeCount; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      // Subtle drift
      final driftX = sin(animation.value * pi * 2 + i) * 3;
      final driftY = cos(animation.value * pi * 2 + i * 0.7) * 3;
      nodes.add(Offset(dx + driftX, dy + driftY));
    }

    // Draw connections between nearby nodes
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < 140) {
          final alpha = ((1 - dist / 140) * 0.08).clamp(0.0, 0.08);
          linePaint.color = AppColors.accentCyan.withValues(alpha: alpha);
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // Draw nodes
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < nodes.length; i++) {
      final baseAlpha = 0.15 + rng.nextDouble() * 0.15;
      dotPaint.color = AppColors.accentCyan.withValues(alpha: baseAlpha);
      final radius = 1.0 + rng.nextDouble() * 1.5;
      canvas.drawCircle(nodes[i], radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}
