import 'package:flutter/material.dart';
import 'package:moji_todo/core/themes/design_tokens.dart';

/// Custom Tab Selector với background color và rounded corners
/// Thiết kế theo Figma mockup cho Report screen
class CustomTabSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<String> tabs;

  const CustomTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FigmaSpacing.lg,
        vertical: FigmaSpacing.sm,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark 
            ? FigmaColors.darkSurface 
            : const Color(0xFFF5F5F5), // Light grey background
        borderRadius: BorderRadius.circular(20),
      ),
      height: 48,
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: _TabItem(
              label: tabs[index],
              isSelected: index == selectedIndex,
              onTap: () => onTabSelected(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected 
              ? FigmaColors.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: FigmaTextStyles.labelMedium.copyWith(
            color: isSelected 
                ? FigmaColors.white
                : (isDark 
                    ? FigmaColors.textDisabled 
                    : FigmaColors.textSecondary),
            fontWeight: isSelected 
                ? FontWeight.w600 
                : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}