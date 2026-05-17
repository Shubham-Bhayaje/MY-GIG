import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';

class CategoryChip extends StatelessWidget {
  final JobCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.15)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? category.color.withValues(alpha: 0.5) : AppColors.divider,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 14,
              color: isSelected ? category.color : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              category.label,
              style: TextStyle(
                color: isSelected ? category.color : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
