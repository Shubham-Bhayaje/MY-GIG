import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';
import 'activity_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'post_job_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    ActivityScreen(),
    SizedBox(), // Placeholder for FAB
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _onPostTap() {
    final state = context.read<AppState>();
    if (!state.isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: const PostJobScreen(),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildBottomNav() {
    final state = context.watch<AppState>();
    final isPoster = !state.isWorkerMode;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: bottomPad + 6),
      decoration: const BoxDecoration(
        color: Color(0xFF050505),
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: isPoster
            ? [
                // Poster: 5 items with center FAB
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.campaign_rounded, Icons.campaign_outlined, 'My Gigs'),
                GestureDetector(
                  onTap: _onPostTap,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_rounded, size: 22, color: Color(0xFF050505)),
                  ),
                ),
                _buildNavItem(3, Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts', showBadge: true),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
              ]
            : [
                // Worker: 4 items, evenly distributed
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.work_rounded, Icons.work_outline_rounded, 'Activity'),
                _buildNavItem(3, Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts', showBadge: true),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
              ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData icon, String label, {bool showBadge = false}) {
    final isActive = _currentIndex == index;
    final state = context.watch<AppState>();
    final hasUnread = showBadge && state.unreadNotificationCount > 0;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentCyan.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive ? AppColors.accentCyan : AppColors.textMuted,
                ),
                if (hasUnread)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.login_rounded,
                  color: AppColors.accentCyan,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login Required',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in or create an account to post gigs and access all features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentCyan,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
