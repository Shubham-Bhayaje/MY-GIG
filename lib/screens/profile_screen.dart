import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = true;
  bool _pushNotifications = true;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final user = state.currentUser;
        // Use real accepted/posted counts
        final acceptedCount = state.acceptedJobs.length;
        final postedCount = state.myPostedJobs.length;

        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: Stack(
            children: [
              // Background — flat
              Container(color: const Color(0xFF050505)),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Top bar
                      Row(
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showSettingsSheet(context, state),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider, width: 0.5),
                              ),
                              child: Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar + Name + Jobs count
                      Column(
                        children: [
                          Stack(
                            children: [
                              UserAvatar(
                                avatarUrl: state.avatarUrl,
                                name: user.name,
                                radius: 40,
                              ),
                              if (user.isVerified)
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGreen, shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primaryDark, width: 2.5),
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user.name.isNotEmpty ? user.name : 'User',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '⚡ ${acceptedCount + postedCount} jobs completed',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 20),

                      // Balance card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WALLET BALANCE',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\u20b9${user.walletBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showWithdrawSheet(context, state),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'Withdraw',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Verified payment text
                      const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 12, color: AppColors.textMuted),
                          SizedBox(width: 4),
                          Text('Verified Payment Method Connected', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats — role-aware
                      Row(
                        children: [
                          if (state.isWorkerMode) ...[
                            Expanded(
                              child: _buildStatCard(
                                'Accepted',
                                '$acceptedCount',
                                Icons.check_circle_outline,
                                AppColors.accentGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (!state.isWorkerMode) ...[
                            Expanded(
                              child: _buildStatCard(
                                'Posted',
                                '$postedCount',
                                Icons.assignment_outlined,
                                AppColors.accentCyan,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                'Active',
                                '${state.myPostedJobs.where((j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress).length}',
                                Icons.local_fire_department_outlined,
                                AppColors.accentCyan,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: _buildStatCard(
                              'Rating',
                              user.rating > 0 ? '${user.rating}' : 'New',
                              Icons.star_border_rounded,
                              AppColors.accentYellow,
                            ),
                          ),
                          if (state.isWorkerMode) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                'Jobs',
                                '${acceptedCount + postedCount}',
                                Icons.bar_chart_rounded,
                                AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ],
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                      // Skills & expertise (Worker only)
                      if (state.isWorkerMode) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Skills & expertise',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showEditSkillsSheet(context, state),
                              child: const Text(
                                '+ Add',
                                style: TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        user.skills.isEmpty
                            ? GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 18, color: AppColors.textMuted),
                                    const SizedBox(width: 8),
                                    Text('Tap "+ Add" to list your skills', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  ],
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: user.skills.map((skill) {
                                  return GestureDetector(
                                    onLongPress: () => _confirmDeleteSkill(context, state, skill),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCyan.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2), width: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline, size: 13, color: AppColors.accentCyan),
                                          const SizedBox(width: 5),
                                          Text(skill, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                      const SizedBox(height: 24),

                      // Activity History section
                      _buildMenuItem(Icons.history_rounded, 'Activity History', AppColors.accentPurple,
                          onTap: () => _showJobHistory(context, state)),
                      _buildMenuItem(Icons.star_rounded, 'My Reviews', AppColors.accentYellow,
                          onTap: () => _showReviews(context, state)),

                      const SizedBox(height: 8),

                      // Account Settings section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text('Account Settings', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      _buildMenuItem(Icons.edit_outlined, 'Edit Profile', AppColors.accentCyan,
                          onTap: () => _showEditProfileSheet(context, state)),
                      _buildMenuItem(Icons.help_outline_rounded, 'Help & Support', AppColors.textSecondary,
                          onTap: () => _showHelpSupport(context)),
                      _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', AppColors.textMuted,
                          onTap: () => _showPrivacyPolicy(context)),
                      _buildMenuItem(Icons.logout_rounded, 'Log Out', AppColors.error,
                          onTap: () => _handleLogout(context)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(iconData, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color == AppColors.error ? AppColors.error : AppColors.textSecondary, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color == AppColors.error ? AppColors.error : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ===== FUNCTIONAL ACTIONS =====

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authService = context.read<AuthService>();
              await authService.signOut();
              final appState = context.read<AppState>();
              appState.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.accentCyan),
            const SizedBox(width: 8),
            Text('$feature — coming soon!'),
          ],
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Settings', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.dark_mode, color: AppColors.textPrimary),
                title: Text('Dark Mode', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text('Always on', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (v) {
                    setSheetState(() => _darkMode = v);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(v ? 'Dark mode enabled' : 'Light mode coming soon — staying dark'),
                        backgroundColor: AppColors.surfaceLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    if (!v) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        setSheetState(() => _darkMode = true);
                        setState(() {});
                      });
                    }
                  },
                  activeColor: AppColors.accentCyan,
                ),
              ),
              ListTile(
                leading: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                title: Text('Push Notifications', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(_pushNotifications ? 'Enabled' : 'Disabled', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                trailing: Switch(
                  value: _pushNotifications,
                  onChanged: (v) {
                    setSheetState(() => _pushNotifications = v);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(children: [
                          Icon(v ? Icons.notifications_active : Icons.notifications_off, color: AppColors.accentCyan),
                          const SizedBox(width: 8),
                          Text(v ? 'Notifications enabled' : 'Notifications disabled'),
                        ]),
                        backgroundColor: AppColors.surfaceLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  activeColor: AppColors.accentCyan,
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on_outlined, color: AppColors.textPrimary),
                title: Text('Location Services', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(_locationServices ? 'Enabled' : 'Disabled', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                trailing: Switch(
                  value: _locationServices,
                  onChanged: (v) {
                    setSheetState(() => _locationServices = v);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(children: [
                          Icon(v ? Icons.location_on : Icons.location_off, color: AppColors.accentCyan),
                          const SizedBox(width: 8),
                          Text(v ? 'Location enabled' : 'Location disabled'),
                        ]),
                        backgroundColor: AppColors.surfaceLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  activeColor: AppColors.accentCyan,
                ),
              ),
              const SizedBox(height: 12),
              // Role switcher
              ListTile(
                leading: Icon(Icons.swap_horiz, color: AppColors.accentPurple),
                title: Text('Account Role', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(
                  state.currentUser.role == UserRole.poster ? 'Poster' : state.currentUser.role == UserRole.worker ? 'Worker' : 'Worker & Poster',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                trailing: PopupMenuButton<UserRole>(
                  color: AppColors.cardBg,
                  icon: Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onSelected: (role) {
                    state.updateUserRole(role);
                    setSheetState(() {});
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(children: [
                          Icon(Icons.check_circle, color: AppColors.accentGreen),
                          const SizedBox(width: 8),
                          Text('Role updated to ${role == UserRole.poster ? 'Poster' : role == UserRole.worker ? 'Worker' : 'Both'}'),
                        ]),
                        backgroundColor: AppColors.surfaceLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: UserRole.worker, child: Text('Worker', style: TextStyle(color: AppColors.textPrimary))),
                    PopupMenuItem(value: UserRole.poster, child: Text('Poster', style: TextStyle(color: AppColors.textPrimary))),
                    PopupMenuItem(value: UserRole.both, child: Text('Both', style: TextStyle(color: AppColors.textPrimary))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: state.currentUser.name);
    final phoneCtrl = TextEditingController(text: state.currentUser.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.person, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.phone, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  state.login(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    uid: state.firebaseUid,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.accentGreen),
                          SizedBox(width: 8),
                          Text('Profile updated!'),
                        ],
                      ),
                      backgroundColor: AppColors.surfaceLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSkillsSheet(BuildContext context, AppState state) {
    final skillCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Skill', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextFormField(
              controller: skillCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g., Photography, Web Dev, Driving...',
                prefixIcon: Icon(Icons.add_circle_outline, color: AppColors.accentCyan),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final skill = skillCtrl.text.trim();
                  if (skill.isNotEmpty) {
                    final newSkills = [...state.currentUser.skills, skill];
                    state.updateSkills(newSkills);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Skill', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJobHistory(BuildContext context, AppState state) {
    final accepted = state.acceptedJobs;
    final posted = state.myPostedJobs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job History', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Expanded(
                child: (accepted.isEmpty && posted.isEmpty)
                    ? Center(child: Text('No job history yet.', style: TextStyle(color: AppColors.textMuted)))
                    : ListView(
                        controller: scrollCtrl,
                        children: [
                          if (accepted.isNotEmpty) ...[
                            Text('Accepted Jobs', style: TextStyle(color: AppColors.accentGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...accepted.map((j) => _historyTile(j.title, j.address, '₹${j.payRate.toStringAsFixed(0)}', AppColors.accentGreen)),
                            const SizedBox(height: 16),
                          ],
                          if (posted.isNotEmpty) ...[
                            Text('Posted Jobs', style: TextStyle(color: AppColors.accentCyan, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...posted.map((j) => _historyTile(j.title, j.address, '₹${j.payRate.toStringAsFixed(0)}', AppColors.accentCyan)),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyTile(String title, String sub, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(color: AppColors.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(amount, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ===== NEW FUNCTIONAL METHODS =====

  void _confirmDeleteSkill(BuildContext context, AppState state, String skill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Skill', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Remove "$skill" from your skills?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = state.currentUser.skills.where((s) => s != skill).toList();
              state.updateSkills(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    Icon(Icons.delete_outline, color: AppColors.accentPink),
                    const SizedBox(width: 8),
                    Text('"$skill" removed'),
                  ]),
                  backgroundColor: AppColors.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context, AppState state) {
    final amountCtrl = TextEditingController();
    final balance = state.currentUser.walletBalance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdraw Funds', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Available balance: ₹${balance.toStringAsFixed(0)}',
              style: TextStyle(color: AppColors.accentGreen, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                labelStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.currency_rupee, color: AppColors.accentGreen),
                hintText: 'Enter amount',
                hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 8),
            // Quick amount buttons
            Row(
              children: [100, 500, 1000].map((amt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text('₹$amt', style: TextStyle(color: AppColors.accentCyan, fontSize: 12)),
                    backgroundColor: AppColors.accentCyan.withValues(alpha: 0.1),
                    side: BorderSide(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                    onPressed: () => amountCtrl.text = '$amt',
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Enter a valid amount'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  if (amount > balance) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Insufficient balance'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(children: [
                        Icon(Icons.check_circle, color: AppColors.accentGreen),
                        const SizedBox(width: 8),
                        Text('₹${amount.toStringAsFixed(0)} withdrawal requested!'),
                      ]),
                      backgroundColor: AppColors.surfaceLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Request Withdrawal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviews(BuildContext context, AppState state) {
    final completedJobs = state.acceptedJobs.where((j) => j.status == JobStatus.completed).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('My Reviews', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: AppColors.accentYellow),
                        const SizedBox(width: 4),
                        Text(
                          state.currentUser.rating > 0 ? state.currentUser.rating.toStringAsFixed(1) : 'New',
                          style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: completedJobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_outline_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text('No reviews yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Complete jobs to get reviews!', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: completedJobs.length,
                        itemBuilder: (ctx, i) {
                          final job = completedJobs[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(job.category.icon, size: 18, color: job.category.color),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(job.title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600))),
                                    Row(
                                      children: List.generate(5, (s) => Icon(Icons.star_rounded, size: 14, color: s < 4 ? AppColors.accentYellow : AppColors.textMuted)),
                                    ),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text('From ${job.posterName}', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help & Support', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _buildHelpItem(
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@hyperlocalgig.com',
              color: AppColors.accentCyan,
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri(scheme: 'mailto', path: 'support@hyperlocalgig.com', queryParameters: {'subject': 'Help Request'});
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            _buildHelpItem(
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '+91 98765 43210',
              color: AppColors.accentGreen,
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri(scheme: 'tel', path: '+919876543210');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            _buildHelpItem(
              icon: Icons.chat_bubble_outline,
              title: 'FAQs',
              subtitle: 'Frequently asked questions',
              color: AppColors.accentPurple,
              onTap: () {
                Navigator.pop(ctx);
                _showFAQs(context);
              },
            ),
            _buildHelpItem(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Help us improve the app',
              color: AppColors.accentOrange,
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri(scheme: 'mailto', path: 'bugs@hyperlocalgig.com', queryParameters: {'subject': 'Bug Report'});
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    final faqs = [
      {'q': 'How do I accept a job?', 'a': 'Go to a job listing, review the details and tap "Accept Job" at the bottom.'},
      {'q': 'How do I get paid?', 'a': 'Payments are credited to your wallet after the poster confirms completion.'},
      {'q': 'Can I cancel an accepted job?', 'a': 'Yes, go to Activity > Accepted tab, and cancel before the job starts.'},
      {'q': 'How do I post a gig?', 'a': 'Tap the + button in the bottom navigation to create and publish a new gig.'},
      {'q': 'Is my data safe?', 'a': 'Yes, we use industry-standard encryption and never share your data with third parties.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FAQs', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: faqs.length,
                  itemBuilder: (ctx, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(top: 8),
                          iconColor: AppColors.accentCyan,
                          collapsedIconColor: AppColors.textMuted,
                          title: Text(faqs[i]['q']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          children: [
                            Text(faqs[i]['a']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Last updated: May 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  children: const [
                    _PolicySection(title: '1. Information We Collect', body: 'We collect personal information you provide such as name, email, phone number, and location when you create an account and use our services. We also collect device information and usage data to improve our app.'),
                    _PolicySection(title: '2. How We Use Your Data', body: 'Your data is used to match you with nearby gig opportunities, process payments, send notifications, and improve the app experience. We do not sell your personal data to third parties.'),
                    _PolicySection(title: '3. Location Data', body: 'We use your device location to show nearby jobs and calculate distances. Location data is only collected while the app is in use and is not stored permanently on our servers.'),
                    _PolicySection(title: '4. Data Security', body: 'We implement industry-standard encryption (TLS/SSL) to protect your data in transit. Your payment information is processed securely through our payment partners.'),
                    _PolicySection(title: '5. Your Rights', body: 'You can update, export, or delete your personal data at any time through the app settings. Contact us at privacy@hyperlocalgig.com for data-related requests.'),
                    _PolicySection(title: '6. Contact', body: 'For privacy concerns, email us at privacy@hyperlocalgig.com or call +91 98765 43210.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.accentCyan, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
