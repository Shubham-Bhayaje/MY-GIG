import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../widgets/glass_card.dart';

class JobCard extends StatelessWidget {
  final GigJob job;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool compact;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.showDistance = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    return GlassCard(
      onTap: onTap,
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 16,
        vertical: compact ? 4 : 5,
      ),
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: category badge + time + urgency
          Row(
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: job.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      job.category.icon,
                      size: 11,
                      color: job.category.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.category.label,
                      style: TextStyle(
                        color: job.category.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 10,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${dateFormat.format(job.dateTime)} · ${_formatDuration(job.duration)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Pay
              Text(
                '₹${job.payRate.toInt()}',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 17 : 19,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            job.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 15 : 16,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (!compact) ...[
            const SizedBox(height: 6),
            // Description
            Text(
              job.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),

          // Bottom row: poster info + distance + accept button
          Row(
            children: [
              // Poster avatar circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      job.category.color.withValues(alpha: 0.4),
                      job.category.color.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    job.posterName.isNotEmpty ? job.posterName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  job.posterName,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star_rounded,
                size: 12,
                color: AppColors.accentYellow,
              ),
              Text(
                ' ${job.posterRating.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: AppColors.accentYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showDistance) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.near_me_rounded,
                  size: 11,
                  color: AppColors.accentCyan,
                ),
                const SizedBox(width: 2),
                Text(
                  '${job.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              // Accept Gig button
              if (job.status == JobStatus.posted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'Accept Gig',
                    style: TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Status badge
              if (job.status != JobStatus.posted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: job.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.status.label,
                    style: TextStyle(
                      color: job.status.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      return minutes > 0
          ? '${duration.inHours}h ${minutes}m'
          : '${duration.inHours}h';
    }
    return '${duration.inMinutes}m';
  }
}
