import 'package:flutter/material.dart';
import '../../../../core/themes/design_tokens.dart';

class TaskCategoryCard extends StatelessWidget {
  final String title;
  final String totalTime;
  final int taskCount;
  final Color borderColor;
  final IconData? icon;
  final Color? iconColor;
  final bool showDetails;
  final bool isCompact;
  final VoidCallback? onTap;

  const TaskCategoryCard({
    super.key,
    required this.title,
    required this.totalTime,
    required this.taskCount,
    required this.borderColor,
    this.icon,
    this.iconColor,
    this.showDetails = true,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Text colors based on theme
    final Color titleTextColor = isDark
        ? FigmaColors.textOnPrimary
        : FigmaColors.textPrimary;
    final Color detailTextColor = isDark
        ? FigmaColors.textTertiary
        : FigmaColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusLg),
          color: isDark
              ? FigmaColors.darkSurface.withOpacity(0.7)
              : theme.cardColor.withOpacity(0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon + Title
              Row(
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        icon,
                        color: iconColor ?? borderColor,
                        size: 18,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: titleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Row 2: Time and task count (if showDetails)
              if (showDetails) ...[
                const SizedBox(height: 6),
                Text(
                  '$totalTime  ($taskCount)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: detailTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}