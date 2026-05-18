import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/job_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: Stack(
            children: [
              // Background — flat
              Container(color: const Color(0xFF050505)),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isWorkerMode ? 'My Activity' : 'My Posted Gigs',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            state.isWorkerMode
                                ? 'Track your accepted gigs and earnings'
                                : 'Manage gigs you\'ve posted',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        ],
                      ),
                    ),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: state.isWorkerMode
                        ? _buildWorkerStats(state)
                        : _buildPosterStats(state),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Tab bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: state.isWorkerMode ? AppColors.accentCyan : AppColors.accentPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorPadding: const EdgeInsets.all(4),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.black, // Dark text on bright pill
                        unselectedLabelColor: AppColors.textMuted,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: state.isWorkerMode
                            ? const [
                                Tab(text: 'Active'),
                                Tab(text: 'Completed'),
                                Tab(text: 'Earnings'),
                              ]
                            : const [
                                Tab(text: 'Open'),
                                Tab(text: 'Active'),
                                Tab(text: 'Done'),
                              ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 8),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: state.isWorkerMode
                            ? [
                                _buildWorkerActiveTab(state),
                                _buildWorkerCompletedTab(state),
                                _buildWorkerEarningsTab(state),
                              ]
                            : [
                                _buildPosterOpenTab(state),
                                _buildPosterActiveTab(state),
                                _buildPosterDoneTab(state),
                              ],
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

  // ===== STATS =====

  Widget _buildWorkerStats(AppState state) {
    final activeCount = state.activeGigs.length;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active',
            '$activeCount',
            AppColors.accentCyan,
            Icons.bolt_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${state.currentUser.completedJobs}',
            AppColors.accentGreen,
            Icons.done_all_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Earned',
            '\u20b9${state.currentUser.walletBalance.toInt()}',
            AppColors.accentOrange,
            Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildPosterStats(AppState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Posted',
            '${state.myPostedJobs.length}',
            AppColors.accentPurple,
            Icons.post_add_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            '${state.myPostedJobs.where((j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress).length}',
            AppColors.accentGreen,
            Icons.play_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Spent',
            '\u20b9${state.myPostedJobs.fold<double>(0, (s, j) => s + j.payRate).toInt()}',
            AppColors.accentOrange,
            Icons.payments_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===== WORKER TABS =====

  /// Shows gigs the worker has accepted and are currently active
  Widget _buildWorkerActiveTab(AppState state) {
    final jobs = state.acceptedJobs.where(
      (j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress,
    ).toList();

    if (jobs.isEmpty) {
      return _buildEmptyState(
        Icons.work_outline_rounded,
        'No active gigs',
        'Browse the map to find and accept gigs',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return JobCard(
          job: jobs[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailScreen(job: jobs[index])),
          ),
        ).animate()
          .fadeIn(delay: (50 * index).ms, duration: 300.ms)
          .slideX(begin: 0.05, duration: 300.ms);
      },
    );
  }

  /// Shows gigs the worker has completed
  Widget _buildWorkerCompletedTab(AppState state) {
    final jobs = state.acceptedJobs.where(
      (j) => j.status == JobStatus.completed,
    ).toList();

    if (jobs.isEmpty) {
      return _buildEmptyState(
        Icons.emoji_events_outlined,
        'No completed gigs yet',
        'Complete gigs to build your reputation',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return JobCard(
          job: jobs[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailScreen(job: jobs[index])),
          ),
        ).animate()
          .fadeIn(delay: (50 * index).ms, duration: 300.ms)
          .slideX(begin: 0.05, duration: 300.ms);
      },
    );
  }

  /// Shows the worker's earnings summary
  Widget _buildWorkerEarningsTab(AppState state) {
    final wallet = state.currentUser.walletBalance;
    final completed = state.currentUser.completedJobs;
    final avgEarning = completed > 0 ? (wallet / completed) : 0.0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Wallet balance card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.accentCyan, size: 36),
              const SizedBox(height: 12),
              Text(
                '\u20b9${wallet.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total Earnings',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _buildEarningsStat(
                'Gigs Done',
                '$completed',
                Icons.check_circle_outline,
                AppColors.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEarningsStat(
                'Avg / Gig',
                '\u20b9${avgEarning.toStringAsFixed(0)}',
                Icons.trending_up_rounded,
                AppColors.accentOrange,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 16),

        // Rating card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Rating', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      state.currentUser.rating > 0
                          ? '${state.currentUser.rating} / 5.0'
                          : 'No ratings yet',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${state.currentUser.totalReviews} reviews',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 16),

        // Tip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.accentYellow),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pro Tip', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                    SizedBox(height: 2),
                    Text('Complete more gigs to unlock verified badge and higher pay opportunities.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildEarningsStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  // ===== POSTER TABS =====

  Widget _buildPosterOpenTab(AppState state) {
    final openGigs = state.myPostedJobs.where((j) => j.status == JobStatus.posted).toList();
    if (openGigs.isEmpty) {
      return _buildEmptyState(
        Icons.hourglass_empty_rounded,
        'No open gigs',
        'Post a gig to find workers nearby',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: openGigs.length,
      itemBuilder: (context, index) {
        final job = openGigs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: JobCard(
            job: job,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosterActiveTab(AppState state) {
    final activeGigs = state.myPostedJobs
        .where((j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress)
        .toList();
    if (activeGigs.isEmpty) {
      return _buildEmptyState(
        Icons.play_circle_outline,
        'No active gigs',
        'Workers who accept your gigs appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: activeGigs.length,
      itemBuilder: (context, index) {
        final job = activeGigs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: JobCard(
            job: job,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosterDoneTab(AppState state) {
    final doneGigs = state.myPostedJobs.where((j) => j.status == JobStatus.completed).toList();
    if (doneGigs.isEmpty) {
      return _buildEmptyState(
        Icons.done_all_rounded,
        'No completed gigs',
        'Completed gigs will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: doneGigs.length,
      itemBuilder: (context, index) {
        final job = doneGigs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              JobCard(
                job: job,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                ),
              ),
              // Rate Worker button — only if there are accepted workers
              if (job.acceptedWorkerIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRateWorkerDialog(context, state, job),
                      icon: const Icon(Icons.star_rounded, size: 18),
                      label: const Text('Rate Worker'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentYellow,
                        side: BorderSide(
                          color: AppColors.accentYellow.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRateWorkerDialog(BuildContext context, AppState state, GigJob job) {
    double selectedRating = 4.0;
    bool submitting = false;
    // Use first worker UID from the accepted list
    final workerUid = job.acceptedWorkerIds.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentYellow,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rate This Worker',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'How was the work on "${job.title}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Star rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starValue = i + 1.0;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedRating = starValue),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: starValue <= selectedRating
                              ? AppColors.accentYellow
                              : AppColors.textMuted,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _ratingLabel(selectedRating),
                  style: TextStyle(
                    color: AppColors.accentYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
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
                        onPressed: submitting
                            ? null
                            : () async {
                                setDialogState(() => submitting = true);
                                final success = await state.rateWorker(
                                  workerUid,
                                  selectedRating,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            success
                                                ? Icons.check_circle
                                                : Icons.error_outline,
                                            color: success
                                                ? AppColors.accentGreen
                                                : AppColors.error,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            success
                                                ? 'Rating submitted! ⭐'
                                                : 'Failed to submit rating',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.surfaceLight,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Submit',
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
      ),
    );
  }

  String _ratingLabel(double rating) {
    if (rating <= 1) return 'Poor';
    if (rating <= 2) return 'Below Average';
    if (rating <= 3) return 'Average';
    if (rating <= 4) return 'Good';
    return 'Excellent';
  }

  // ===== SHARED =====

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
