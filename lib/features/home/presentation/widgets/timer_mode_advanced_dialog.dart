import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/home_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/constants/strings.dart';

class TimerModeAdvancedDialog extends StatefulWidget {
  final VoidCallback? onSwitchToSimple;

  const TimerModeAdvancedDialog({
    super.key,
    this.onSwitchToSimple,
  });

  /// Show bottom sheet helper method
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSwitchToSimple,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerModeAdvancedDialog(
        onSwitchToSimple: onSwitchToSimple,
      ),
    );
  }

  @override
  State<TimerModeAdvancedDialog> createState() => _TimerModeAdvancedDialogState();
}

class _TimerModeAdvancedDialogState extends State<TimerModeAdvancedDialog> {
  late String timerMode;
  late int workDuration;
  late int breakDuration;
  late bool soundEnabled;
  late bool autoSwitch;
  late String notificationSound;
  late int totalSessions;

  late TextEditingController workController;
  late TextEditingController breakController;
  late TextEditingController sessionsController;

  @override
  void initState() {
    super.initState();
    final homeState = context.read<HomeCubit>().state;

    timerMode = homeState.timerMode;
    workDuration = homeState.workDuration;
    breakDuration = homeState.breakDuration;
    soundEnabled = homeState.soundEnabled;
    autoSwitch = homeState.autoSwitch;
    notificationSound = homeState.notificationSound;
    totalSessions = homeState.totalSessions;

    workController = TextEditingController(text: workDuration.toString());
    breakController = TextEditingController(text: breakDuration.toString());
    sessionsController = TextEditingController(text: totalSessions.toString());
  }

  @override
  void dispose() {
    workController.dispose();
    breakController.dispose();
    sessionsController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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

          // Content - Scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Timer Mode Dropdown
                  _buildCard(
                    context: context,
                    child: DropdownButtonFormField<String>(
                      value: timerMode,
                      decoration: InputDecoration(
                        labelText: AppStrings.timerModeLabel,
                        labelStyle: GoogleFonts.inter(
                          fontSize: AppSizes.labelFontSize - 2,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.textPrimary,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Theme.of(context).cardTheme.color
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '25:00 - 00:00',
                          child: Text(AppStrings.timerModePomodoro),
                        ),
                        DropdownMenuItem(
                          value: '00:00 - 0∞',
                          child: Text(AppStrings.timerModeCountUpInfinite),
                        ),
                        DropdownMenuItem(
                          value: 'Tùy chỉnh',
                          child: Text(AppStrings.timerModeCustom),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          timerMode = value ?? '25:00 - 00:00';
                          if (timerMode == '25:00 - 00:00') {
                            workDuration = 25;
                            breakDuration = 5;
                            workController.text = '25';
                            breakController.text = '5';
                          } else if (timerMode == '00:00 - 0∞') {
                            workDuration = 0;
                            breakDuration = 0;
                            workController.text = '0';
                            breakController.text = '0';
                          }
                        });
                      },
                    ),
                  ),

                  // Custom Duration Fields (only show if custom mode)
                  if (timerMode == 'Tùy chỉnh') ...[
                    const SizedBox(height: AppSizes.spacing / 2),
                    _buildCard(
                      context: context,
                      child: TextField(
                        controller: workController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: AppStrings.workDurationLabel,
                          labelStyle: GoogleFonts.inter(
                            fontSize: AppSizes.labelFontSize - 2,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.textPrimary,
                          ),
                          hintText: AppStrings.workDurationHelper,
                          hintStyle: GoogleFonts.inter(
                            fontSize: AppSizes.helperFontSize,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : AppColors.textDisabled,
                          ),
                          prefixIcon: Icon(
                            Icons.timer,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : AppColors.textDisabled,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Theme.of(context).cardTheme.color
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed == null || parsed < 1 || parsed > 480) {
                            workDuration = 25;
                            workController.text = '25';
                          } else {
                            workDuration = parsed;
                          }
                          setState(() {});
                        },
                        onChanged: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 1 && parsed <= 480) {
                            workDuration = parsed;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing / 2),
                    _buildCard(
                      context: context,
                      child: TextField(
                        controller: breakController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: AppStrings.breakDurationLabel,
                          labelStyle: GoogleFonts.inter(
                            fontSize: AppSizes.labelFontSize - 2,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.textPrimary,
                          ),
                          hintText: AppStrings.breakDurationHelper,
                          hintStyle: GoogleFonts.inter(
                            fontSize: AppSizes.helperFontSize,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : AppColors.textDisabled,
                          ),
                          prefixIcon: Icon(
                            Icons.timer,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : AppColors.textDisabled,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Theme.of(context).cardTheme.color
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed == null || parsed < 1 || parsed > 60) {
                            breakDuration = 5;
                            breakController.text = '5';
                          } else {
                            breakDuration = parsed;
                          }
                          setState(() {});
                        },
                        onChanged: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 1 && parsed <= 60) {
                            breakDuration = parsed;
                          }
                        },
                      ),
                    ),
                  ],

                  // Sessions Count
                  const SizedBox(height: AppSizes.spacing / 2),
                  _buildCard(
                    context: context,
                    child: TextField(
                      controller: sessionsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: AppStrings.sessionsLabel,
                        labelStyle: GoogleFonts.inter(
                          fontSize: AppSizes.labelFontSize - 2,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.textPrimary,
                        ),
                        hintText: AppStrings.sessionsHelper,
                        hintStyle: GoogleFonts.inter(
                          fontSize: AppSizes.helperFontSize,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                              : AppColors.textDisabled,
                        ),
                        prefixIcon: Icon(
                          Icons.repeat,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                              : AppColors.textDisabled,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Theme.of(context).cardTheme.color
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) {
                        int? parsed = int.tryParse(value);
                        if (parsed == null || parsed < 1 || parsed > 10) {
                          totalSessions = 4;
                          sessionsController.text = '4';
                        } else {
                          totalSessions = parsed;
                        }
                        setState(() {});
                      },
                      onChanged: (value) {
                        int? parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 1 && parsed <= 10) {
                          totalSessions = parsed;
                        }
                      },
                    ),
                  ),

                  // Sound Settings
                  const SizedBox(height: AppSizes.spacing / 2),
                  _buildCard(
                    context: context,
                    child: CheckboxListTile(
                      title: Text(
                        AppStrings.soundLabel,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.labelFontSize - 2,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.soundHelper,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.helperFontSize,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                              : AppColors.textSecondary,
                        ),
                      ),
                      value: soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          soundEnabled = value ?? true;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                      checkColor: Theme.of(context).colorScheme.onSecondary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  // Sound Type Dropdown (only show if sound enabled)
                  if (soundEnabled) ...[
                    const SizedBox(height: AppSizes.spacing / 2),
                    _buildCard(
                      context: context,
                      child: DropdownButtonFormField<String>(
                        value: notificationSound,
                        decoration: InputDecoration(
                          labelText: AppStrings.notificationSoundLabel,
                          labelStyle: GoogleFonts.inter(
                            fontSize: AppSizes.labelFontSize - 2,
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.textPrimary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Theme.of(context).cardTheme.color
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'bell', child: Text(AppStrings.soundBell)),
                          DropdownMenuItem(value: 'chime', child: Text(AppStrings.soundChime)),
                          DropdownMenuItem(value: 'alarm', child: Text(AppStrings.soundAlarm)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            notificationSound = value ?? 'bell';
                          });
                        },
                      ),
                    ),
                  ],

                  // Auto Switch
                  const SizedBox(height: AppSizes.spacing / 2),
                  _buildCard(
                    context: context,
                    child: CheckboxListTile(
                      title: Text(
                        AppStrings.autoSwitchLabel,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.labelFontSize - 2,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.autoSwitchHelper,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.helperFontSize,
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                              : AppColors.textSecondary,
                        ),
                      ),
                      value: autoSwitch,
                      onChanged: (value) {
                        setState(() {
                          autoSwitch = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                      checkColor: Theme.of(context).colorScheme.onSecondary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Link to Simple Mode
                  if (widget.onSwitchToSimple != null)
                    GestureDetector(
                      onTap: widget.onSwitchToSimple,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.toggle_off,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.switchToSimple,
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
          ),

          // Divider
          const Divider(height: 1),

          // Footer - Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
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

  Widget _buildCard({required BuildContext context, required Widget child}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).cardTheme.color
          : AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  void _handleOk(BuildContext context) {
    // Validate inputs
    if (workController.text.isEmpty || workDuration < 1 || workDuration > 480) {
      workDuration = 25;
    }
    if (breakController.text.isEmpty || breakDuration < 1 || breakDuration > 60) {
      breakDuration = 5;
    }
    if (sessionsController.text.isEmpty || totalSessions < 1 || totalSessions > 10) {
      totalSessions = 4;
    }

    // Update timer mode in cubit
    context.read<HomeCubit>().updateTimerMode(
      timerMode: timerMode,
      workDuration: workDuration,
      breakDuration: breakDuration,
      soundEnabled: soundEnabled,
      autoSwitch: autoSwitch,
      notificationSound: notificationSound,
      totalSessions: totalSessions,
    );

    Navigator.pop(context);
  }
}