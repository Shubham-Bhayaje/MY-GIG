import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: AppColors.surfaceLight,
            highlightColor: AppColors.cardBgElevated,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              color: AppColors.surfaceLight,
            ),
          ),
          errorWidget: (context, url, error) => _buildInitials(),
        ),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.accentCyan.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.accentCyan,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
