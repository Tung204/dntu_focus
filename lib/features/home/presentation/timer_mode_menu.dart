import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/home_cubit.dart';
import '../domain/home_state.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/constants/strings.dart';
import 'widgets/timer_mode_simple_dialog.dart';
import 'widgets/timer_mode_advanced_dialog.dart';

class TimerModeMenu extends StatelessWidget {
  const TimerModeMenu({super.key});

  void _showTimerModeMenu(BuildContext context) {
    final homeState = context.read<HomeCubit>().state;

    bool isEditable = (!homeState.isTimerRunning && !homeState.isPaused) ||
        (!homeState.isCountingUp && homeState.timerSeconds <= 0);

    if (!isEditable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.timerRunningError),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show Simple Dialog by default (can be changed to Advanced if needed)
    _showSimpleDialog(context);
  }

  void _showSimpleDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TimerModeSimpleDialog(
        onSwitchToAdvanced: () {
          Navigator.pop(context);
          _showAdvancedDialog(context);
        },
      ),
    );
  }

  void _showAdvancedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TimerModeAdvancedDialog(
        onSwitchToSimple: () {
          Navigator.pop(context);
          _showSimpleDialog(context);
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isTimerRunning != current.isTimerRunning ||
          previous.isPaused != current.isPaused ||
          previous.timerSeconds != current.timerSeconds ||
          previous.isCountingUp != current.isCountingUp,
      builder: (context, state) {
        final isEditable = (!state.isTimerRunning && !state.isPaused) ||
            (!state.isCountingUp && state.timerSeconds <= 0);

        return GestureDetector(
          onTap: () {
            _showTimerModeMenu(context);
          },
          child: Tooltip(
            message: isEditable
                ? 'Chỉnh chế độ đồng hồ'
                : 'Dừng đồng hồ hoàn toàn hoặc chờ hết giờ để thay đổi',
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    color: isEditable
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    size: AppSizes.iconSize,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.timerModeTitle,
                    style: GoogleFonts.inter(
                      color: isEditable
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}