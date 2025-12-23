import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moji_todo/features/home/presentation/strict_mode_menu.dart';
import 'package:moji_todo/features/home/presentation/timer_mode_menu.dart';
import 'package:moji_todo/features/home/presentation/white_noise_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tasks/data/models/task_model.dart';
import '../domain/home_cubit.dart';
import '../domain/home_state.dart';
import 'home_screen_state_manager.dart';
import 'task_bottom_sheet.dart';
import 'widgets/pomodoro_timer.dart';
import '../../tasks/domain/task_cubit.dart';
import '../../../core/themes/design_tokens.dart';

/// Home Screen theo Figma - Focusify UI Kit
/// Màu chính: Đỏ cà chua #FF6347 (255, 99, 71)
/// Font: Urbanist
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
    TaskBottomSheet.show(context, (taskTitle, estimatedPomodoros) {
      context.read<HomeCubit>().selectTask(taskTitle, estimatedPomodoros);
    }, (task) {
      final taskCubit = context.read<TaskCubit>();
      Task? taskToComplete;
      try {
        taskToComplete = taskCubit.state.tasks.firstWhere((t) => t.id == task.id);
      } catch (e) {
        // ignore: avoid_print
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
    });
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
                (task) => task.title == selectedTaskTitle && task.isCompleted != true,
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFFFF6347),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    final horizontalPadding = screenWidth * 0.06;
                    
                    // Tính toán kích thước cố định để tránh overflow
                    final headerHeight = screenHeight * 0.12;
                    final taskSelectorHeight = screenHeight * 0.10;
                    final timerHeight = screenHeight * 0.40;
                    final indicatorHeight = screenHeight * 0.06;
                    final settingsHeight = screenHeight * 0.20;
                    
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: screenHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Header
                              SizedBox(
                                height: headerHeight,
                                child: _buildCompactHeader(context),
                              ),
                              
                              // Content area
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                  child: Column(
                                    children: [
                                      // Spacing top
                                      const SizedBox(height: 16),
                                      
                                      // Task Selector
                                      SizedBox(
                                        height: taskSelectorHeight,
                                        child: _buildTaskSelector(context, state),
                                      ),
                                      
                                      const Spacer(flex: 2),
                                      
                                      // Pomodoro Timer
                                      SizedBox(
                                        height: timerHeight,
                                        child: Center(
                                          child: PomodoroTimer(stateManager: _stateManager),
                                        ),
                                      ),
                                      
                                      const Spacer(flex: 1),
                                      
                                      // Current task indicator
                                      if (state.selectedTask != null)
                                        SizedBox(
                                          height: indicatorHeight,
                                          child: Center(
                                            child: _buildCurrentTaskIndicator(state.selectedTask!),
                                          ),
                                        )
                                      else
                                        SizedBox(height: indicatorHeight),
                                      
                                      const Spacer(flex: 1),
                                      
                                      // Quick Settings
                                      SizedBox(
                                        height: settingsHeight,
                                        child: _buildQuickSettings(),
                                      ),
                                      
                                      const SizedBox(height: 16),
                                    ],
                                  ),
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

  Widget _buildCompactHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: FigmaSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left icon - Menu
          IconButton(
            icon: Icon(
              Icons.menu,
              color: FigmaColors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
          // Center - App name
          Text(
            'Focusify',
            style: FigmaTextStyles.h3.copyWith(
              color: FigmaColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Right icon - Notifications
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: FigmaColors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSelector(BuildContext context, HomeState state) {
    return GestureDetector(
      onTap: () => _showTaskBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: FigmaSpacing.md,
          vertical: FigmaSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: FigmaColors.white,
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusLg),
        ),
        child: Row(
          children: [
            // Icon - Radio button style
            Icon(
              state.selectedTask != null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: FigmaColors.primary,
              size: 24,
            ),
            SizedBox(width: FigmaSpacing.md),
            // Text
            Expanded(
              child: Text(
                state.selectedTask ?? 'Create a Design Wireframe',
                style: FigmaTextStyles.labelMedium.copyWith(
                  color: FigmaColors.textPrimary,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Close icon
            IconButton(
              icon: Icon(
                Icons.close,
                color: FigmaColors.textSecondary,
                size: 20,
              ),
              onPressed: state.selectedTask != null
                  ? () => context.read<HomeCubit>().resetTask()
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTaskIndicator(String taskName) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: FigmaSpacing.md,
        vertical: FigmaSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FigmaColors.primary.withOpacity(0.1),
            FigmaColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        border: Border.all(
          color: FigmaColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: FigmaColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: FigmaSpacing.sm),
          Flexible(
            child: Text(
              'Đang focus: $taskName',
              style: FigmaTextStyles.bodySmall.copyWith(
                color: FigmaColors.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSettingIcon(Icons.block, 'Strict Mode'),
        _buildSettingIcon(Icons.hourglass_empty, 'Timer Mode'),
        _buildSettingIcon(Icons.music_note, 'White Noise'),
      ],
    );
  }

  Widget _buildSettingIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: FigmaColors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: FigmaColors.white,
            size: 28,
          ),
        ),
        SizedBox(height: FigmaSpacing.xs),
        Text(
          label,
          style: FigmaTextStyles.bodySmall.copyWith(
            color: FigmaColors.white,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
