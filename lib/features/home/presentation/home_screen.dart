import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tasks/data/models/task_model.dart';
import '../domain/home_cubit.dart';
import '../domain/home_state.dart';
import 'home_screen_state_manager.dart';
import 'task_bottom_sheet.dart';
import '../../tasks/domain/task_cubit.dart';
import '../../../core/themes/design_tokens.dart';
import 'widgets/strict_mode_dialog.dart';
import 'widgets/timer_mode_simple_dialog.dart';
import 'widgets/timer_mode_advanced_dialog.dart';
import 'widgets/white_noise_dialog.dart';
import '../../../routes/app_routes.dart';

/// Home Screen theo Figma Design - Focusify UI Kit
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeScreenStateManager? _stateManager;

  @override
  void initState() {
    super.initState();
    _stateManager = HomeScreenStateManager(
      context: context,
      sharedPreferences: SharedPreferences.getInstance(),
      onShowTaskBottomSheet: _showTaskBottomSheet,
    );
    WidgetsBinding.instance.addObserver(this);
    _stateManager!.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _stateManager?.handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    _stateManager?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showTaskBottomSheet(BuildContext context) {
    TaskBottomSheet.show(
      context,
      (taskTitle, estimatedPomodoros) {
        context.read<HomeCubit>().selectTask(taskTitle, estimatedPomodoros);
      },
      (task) {
        final taskCubit = context.read<TaskCubit>();
        Task? taskToComplete;
        try {
          taskToComplete = taskCubit.state.tasks.firstWhere(
            (t) => t.id == task.id,
          );
        } catch (e) {
          print("Task to complete not found in TaskCubit: ${task.id}");
        }

        if (taskToComplete != null) {
          taskCubit.updateTask(taskToComplete.copyWith(isCompleted: true));
        } else {
          taskCubit.updateTask(task.copyWith(isCompleted: true));
        }

        final homeCubit = context.read<HomeCubit>();
        if (homeCubit.state.selectedTask == task.title) {
          homeCubit.resetTask();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskCubit, TaskState>(
          listener: (context, taskState) {
            final homeCubit = context.read<HomeCubit>();
            final selectedTaskTitle = homeCubit.state.selectedTask;
            if (selectedTaskTitle != null) {
              final tasksFromTaskCubit = context.read<TaskCubit>().state.tasks;
              final isTaskStillValid = tasksFromTaskCubit.any(
                (task) =>
                    task.title == selectedTaskTitle && task.isCompleted != true,
              );
              if (!isTaskStillValid) {
                homeCubit.resetTask();
              }
            }
          },
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              if (state.isStrictModeEnabled &&
                  state.isTimerRunning &&
                  state.isExitBlockingEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Strict Mode đang bật! Không thể thoát ứng dụng.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: FigmaColors.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return false;
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: FigmaColors.primary,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;
                    final screenWidth = constraints.maxWidth;

                    // Tính toán kích thước timer dựa trên màn hình
                    final timerSize = (screenWidth * 0.7).clamp(220.0, 300.0);

                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Top AppBar
                              _buildTopBar(context, screenWidth),

                              SizedBox(height: screenHeight * 0.012),

                              // Task Selector (trong vùng cam)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.06,
                                ),
                                child: _buildTaskCard(
                                  context,
                                  state,
                                  screenWidth,
                                ),
                              ),

                              // Stack để tạo hiệu ứng timer nửa trên nền cam, nửa trên nền trắng
                              Expanded(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Nền trắng phía dưới
                                    Positioned(
                                      top: timerSize * 0.35,
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Nội dung chính
                                    Positioned.fill(
                                      child: Column(
                                        children: [
                                          SizedBox(height: screenHeight * 0.02),

                                          // Timer Circle
                                          _buildTimerCircle(state, timerSize),

                                          SizedBox(height: screenHeight * 0.10),

                                          // Buttons
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.06,
                                            ),
                                            child:
                                                state.isPaused
                                                    ? _buildPauseButtons(
                                                      context,
                                                      state,
                                                      screenWidth,
                                                    )
                                                    : _buildStartButton(
                                                      context,
                                                      state,
                                                      screenWidth,
                                                    ),
                                          ),

                                          SizedBox(height: screenHeight * 0.04),

                                          // Quick Settings Icons (3 icon ngang)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.06,
                                            ),
                                            child: _buildQuickSettingsIcons(
                                              context,
                                              state,
                                              screenWidth,
                                            ),
                                          ),

                                          SizedBox(
                                            height: screenHeight * 0.015,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double screenWidth) {
    final iconSize = screenWidth < 360 ? 22.0 : 26.0;
    final titleSize = screenWidth < 360 ? 18.0 : 20.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: iconSize,
          ),
          Text(
            'Moji Focus',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            child: Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    HomeState state,
    double screenWidth,
  ) {
    final fontSize = screenWidth < 360 ? 13.0 : 15.0;

    return GestureDetector(
      onTap: () => _showTaskBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.045,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.selectedTask ?? 'Select Task',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color:
                      state.selectedTask != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: screenWidth < 360 ? 20 : 24,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle(HomeState state, double timerSize) {
    final minutes = (state.timerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.timerSeconds % 60).toString().padLeft(2, '0');

    // Tính progress
    final totalDuration =
        (state.isWorkSession ? state.workDuration : state.breakDuration) * 60;
    double progress = 0.0;
    if (totalDuration > 0 && !state.isCountingUp) {
      progress = 1.0 - (state.timerSeconds / totalDuration);
    }
    progress = progress.clamp(0.0, 1.0);

    // Session text
    String sessionText;
    if (state.isTimerRunning || state.isPaused) {
      sessionText = '${state.currentSession} / ${state.totalSessions} sessions';
    } else {
      sessionText = 'No sessions';
    }

    final timeFontSize = timerSize * 0.22;
    final sessionFontSize = timerSize * 0.06;
    final strokeWidth = timerSize * 0.045;

    return Container(
      width: timerSize,
      height: timerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1
            ),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Circle
          SizedBox(
            width: timerSize - 16,
            height: timerSize - 16,
            child: CircularProgressIndicator(
              value: state.isCountingUp ? null : progress,
              strokeWidth: strokeWidth,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Time & Session Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes:$seconds',
                style: TextStyle(
                  fontSize: timeFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sessionText,
                style: TextStyle(
                  fontSize: sessionFontSize,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    HomeState state,
    double screenWidth,
  ) {
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;
    final buttonHeight = screenWidth < 360 ? 48.0 : 52.0;

    // Xác định text và hành động dựa trên trạng thái
    String buttonText;
    VoidCallback onPressed;

    if (state.isTimerRunning && !state.isPaused) {
      // Đang chạy -> hiện nút Pause
      buttonText = 'Pause';
      onPressed = () => context.read<HomeCubit>().pauseTimer();
    } else if (state.isPaused) {
      // Đang pause -> hiện nút Continue
      buttonText = 'Continue';
      onPressed = () => context.read<HomeCubit>().continueTimer();
    } else {
      // Chưa bắt đầu -> hiện nút Start
      buttonText = 'Start to Focus';
      onPressed = () => context.read<HomeCubit>().startTimer();
    }

    return SizedBox(
      width: double.infinity,
      height: screenWidth < 360 ? 54.0 : 58.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: FigmaColors.primary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (buttonText != 'Pause') ...[
              Icon(Icons.play_arrow, size: fontSize + 6, color: Colors.white),
              const SizedBox(width: 8),
            ] else ...[
              Icon(Icons.pause, size: fontSize + 6, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              buttonText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton(
    BuildContext context,
    HomeState state,
    double screenWidth,
  ) {
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;
    final buttonHeight = screenWidth < 360 ? 48.0 : 52.0;

    return SizedBox(
      width: double.infinity,
      height: screenWidth < 360 ? 54.0 : 58.0,
      child: ElevatedButton(
        onPressed: () {
          context.read<HomeCubit>().stopTimer();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Stop',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Colors.red.shade700,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildPauseButtons(
    BuildContext context,
    HomeState state,
    double screenWidth,
  ) {
    return Row(
      children: [
        Expanded(child: _buildStopButton(context, state, screenWidth)),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          flex: 2,
          child: _buildContinueButton(context, state, screenWidth),
        ),
      ],
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    HomeState state,
    double screenWidth,
  ) {
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;
    final buttonHeight = screenWidth < 360 ? 48.0 : 52.0;

    return SizedBox(
      width: double.infinity,
      height: screenWidth < 360 ? 54.0 : 58.0,
      child: ElevatedButton(
        onPressed: () {
          context.read<HomeCubit>().continueTimer();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: FigmaColors.primary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildQuickSettingsIcons(
    BuildContext context,
    HomeState state,
    double screenWidth,
  ) {
    final iconSize = screenWidth < 360 ? 24.0 : 28.0;
    final labelSize = screenWidth < 360 ? 10.0 : 11.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSettingIcon(
          icon: Icons.block,
          label: 'Strict Mode',
          iconSize: iconSize,
          labelSize: labelSize,
          isActive: state.isStrictModeEnabled,
          onTap: () => _showStrictModeDialog(context),
        ),
        _buildSettingIcon(
          icon: Icons.hourglass_bottom,
          label: 'Timer Mode',
          iconSize: iconSize,
          labelSize: labelSize,
          isActive: false,
          onTap: () => _showTimerModeDialog(context, state),
        ),
        _buildSettingIcon(
          icon: Icons.music_note,
          label: 'White Noise',
          iconSize: iconSize,
          labelSize: labelSize,
          isActive: state.isWhiteNoiseEnabled,
          onTap: () => _showWhiteNoiseDialog(context, state),
        ),
      ],
    );
  }

  Widget _buildSettingIcon({
    required IconData icon,
    required String label,
    required double iconSize,
    required double labelSize,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconSize * 0.4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? FigmaColors.primary.withOpacity(0.1) : null,
                border: Border.all(
                  color: isActive
                    ? FigmaColors.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: isActive
                  ? FigmaColors.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                color: isActive
                  ? FigmaColors.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showStrictModeDialog(BuildContext context) {
    StrictModeDialog.show(context);
  }

  void _showTimerModeDialog(BuildContext context, HomeState state) {
    // Check if timer is editable
    bool isEditable = (!state.isTimerRunning && !state.isPaused) ||
        (!state.isCountingUp && state.timerSeconds <= 0);

    if (!isEditable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng dừng timer hoàn toàn hoặc chờ hết giờ để chỉnh Timer Mode!'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show Simple Dialog by default
    _showSimpleDialog(context);
  }

  void _showSimpleDialog(BuildContext context) {
    TimerModeSimpleDialog.show(
      context,
      onSwitchToAdvanced: () {
        Navigator.pop(context);
        _showAdvancedDialog(context);
      },
    );
  }

  void _showAdvancedDialog(BuildContext context) {
    TimerModeAdvancedDialog.show(
      context,
      onSwitchToSimple: () {
        Navigator.pop(context);
        _showSimpleDialog(context);
      },
    );
  }

  void _showWhiteNoiseDialog(BuildContext context, HomeState state) {
    WhiteNoiseDialog.show(context);
  }
}
