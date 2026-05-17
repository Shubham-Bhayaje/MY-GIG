import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: Stack(
            children: [
              Container(color: const Color(0xFF050505)),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (state.unreadNotificationCount > 0)
                            GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              borderRadius: 20,
                              onTap: () => state.markAllNotificationsRead(),
                              child: const Text(
                                'Mark all read',
                                style: TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    // Notification list
                    Expanded(
                      child: state.notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      size: 48,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No notifications yet',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      'We\'ll notify you when nearby gigs appear or when your gig status changes.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  OutlinedButton(
                                    onPressed: () {
                                      // Could switch tab to Home, but keeping it simple
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(color: AppColors.divider),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text('Explore gigs', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: state.notifications.length,
                              itemBuilder: (context, index) {
                                final notif = state.notifications[index];
                                return _buildNotificationItem(
                                  notif,
                                  index,
                                  state,
                                ).animate()
                                  .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                                  .slideX(begin: 0.05, duration: 300.ms);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> notif,
    int index,
    AppState state,
  ) {
    final isRead = notif['read'] as bool;
    final type = notif['type'] as String;
    final time = notif['time'] as DateTime;

    IconData icon;
    Color color;
    switch (type) {
      case 'accepted':
        icon = Icons.check_circle_rounded;
        color = AppColors.accentGreen;
        break;
      case 'new_job':
        icon = Icons.work_rounded;
        color = AppColors.accentCyan;
        break;
      case 'payment':
        icon = Icons.currency_rupee_rounded;
        color = AppColors.accentGreen;
        break;
      case 'review':
        icon = Icons.star_rounded;
        color = AppColors.accentYellow;
        break;
      case 'completed':
        icon = Icons.task_alt_rounded;
        color = AppColors.accentPurple;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.accentCyan;
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: () => state.markNotificationRead(index),
      borderColor: isRead ? null : color.withValues(alpha: 0.3),
      opacity: isRead ? 0.05 : 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'] as String,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif['body'] as String,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }
}
