import 'package:flutter/material.dart';
import '../../../../core/themes/design_tokens.dart';
import '../../../../core/constants/app_strings.dart';

/// Search bar widget for Task Manager Screen
/// Designed according to Figma with rounded corners and light gray background
///
/// NOTE: Basic search functionality has been implemented.
/// To filter tasks by search query, add logic to TaskCubit or parent widget.
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSearch,
    this.hintText = AppStrings.search,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide clear button
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? FigmaColors.darkSurface : FigmaColors.surface,
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSearch != null ? (_) => widget.onSearch!() : null,
        style: FigmaTextStyles.input.copyWith(
          color: isDark ? FigmaColors.textOnPrimary : FigmaColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: FigmaTextStyles.hint.copyWith(
            color: isDark
                ? FigmaColors.textTertiary
                : FigmaColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark
                ? FigmaColors.textTertiary
                : FigmaColors.textSecondary,
            size: FigmaSpacing.iconSize,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark
                        ? FigmaColors.textTertiary
                        : FigmaColors.textSecondary,
                    size: FigmaSpacing.iconSize,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}