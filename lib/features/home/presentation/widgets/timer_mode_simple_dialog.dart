import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/home_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/constants/strings.dart';

class TimerModeSimpleDialog extends StatefulWidget {
  final VoidCallback? onSwitchToAdvanced;

  const TimerModeSimpleDialog({
    super.key,
    this.onSwitchToAdvanced,
  });

  /// Show bottom sheet helper method
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSwitchToAdvanced,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerModeSimpleDialog(
        onSwitchToAdvanced: onSwitchToAdvanced,
      ),
    );
  }

  @override
  State<TimerModeSimpleDialog> createState() => _TimerModeSimpleDialogState();
}

class _TimerModeSimpleDialogState extends State<TimerModeSimpleDialog> {
  String selectedMode = '25:00 → 00:00'; // Default to countdown

  @override
  void initState() {
    super.initState();
    final homeState = context.read<HomeCubit>().state;
    // Set initial value based on current timer mode
    if (homeState.timerMode == '00:00 - 0∞') {
      selectedMode = '00:00 → ∞';
    } else {
      selectedMode = '25:00 → 00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Text(
              AppStrings.timerModeTitle,
              style: GoogleFonts.inter(
                fontSize: AppSizes.titleFontSize,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Theme.of(context).textTheme.titleLarge!.color
                    : AppColors.textPrimary,
              ),
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Content - Radio Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Option 1: 25:00 → 00:00
                _buildRadioOption(
                  context: context,
                  value: '25:00 → 00:00',
                  title: AppStrings.timerModeCountdownTitle,
                  description: AppStrings.timerModeCountdownDesc,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Option 2: 00:00 → ∞
                _buildRadioOption(
                  context: context,
                  value: '00:00 → ∞',
                  title: AppStrings.timerModeCountUpTitle,
                  description: AppStrings.timerModeCountUpDesc,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Link to Advanced Mode
                if (widget.onSwitchToAdvanced != null)
                  GestureDetector(
                    onTap: widget.onSwitchToAdvanced,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.switchToAdvanced,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Footer - Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    label: AppStrings.cancel,
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: AppColors.cancelButton,
                    textColor: AppColors.textPrimary,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: AppStrings.ok,
                    onPressed: () => _handleOk(context),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String value,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final isSelected = selectedMode == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
              : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio Button
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                          : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOk(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();

    // Map selected mode to timer mode values
    if (selectedMode == '25:00 → 00:00') {
      // Pomodoro mode: 25 min work, 5 min break
      homeCubit.updateTimerMode(
        timerMode: '25:00 - 00:00',
        workDuration: 25,
        breakDuration: 5,
        soundEnabled: homeCubit.state.soundEnabled,
        autoSwitch: homeCubit.state.autoSwitch,
        notificationSound: homeCubit.state.notificationSound,
        totalSessions: homeCubit.state.totalSessions,
      );
    } else {
      // Count up mode: infinite counting
      homeCubit.updateTimerMode(
        timerMode: '00:00 - 0∞',
        workDuration: 0,
        breakDuration: 0,
        soundEnabled: homeCubit.state.soundEnabled,
        autoSwitch: false, // Auto-switch doesn't make sense for count up
        notificationSound: homeCubit.state.notificationSound,
        totalSessions: homeCubit.state.totalSessions,
      );
    }

    Navigator.pop(context);
  }
}