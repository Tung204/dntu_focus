import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tasks/data/models/task_model.dart';
import '../domain/home_cubit.dart';
import '../domain/home_state.dart';
import 'home_screen_state_manager.dart';
import 'task_bottom_sheet.dart';
import 'widgets/pomodoro_timer.dart';
import '../../tasks/domain/task_cubit.dart';
import '../../../core/themes/design_tokens.dart';

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
    TaskBottomSheet.show(context, (taskTitle, estimatedPomodoros) {
      context.read<HomeCubit>().selectTask(taskTitle, estimatedPomodoros);
    }, (task) {
      final taskCubit = context.read<TaskCubit>();
      Task? taskToComplete;
      try {
        taskToComplete = taskCubit.state.tasks.firstWhere((t) => t.id == task.id);
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
                    backgroundColor: FigmaColors.primary,
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
                    
                    return Column(
                      children: [
                        // Top AppBar (màu đỏ)
                        _buildTopBar(screenWidth),
                        
                        // Main Content Area (màu trắng với bo góc)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Task Card
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    screenWidth * 0.05,
                                    screenHeight * 0.025,
                                    screenWidth * 0.05,
                                    0,
                                  ),
                                  child: _buildTaskCard(context, state, screenWidth),
                                ),
                                
                                // Timer Circle - Expanded để tự động scale
                                Expanded(
                                  flex: 8,
                                  child: Center(
                                    child: _buildTimerSection(state, screenWidth, screenHeight),
                                  ),
                                ),
                                
                                // Pause Button
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.15,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  child: _buildPauseButton(context, state, screenWidth),
                                ),
                                
                                // Quick Settings Icons (3 icon ngang)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.1,
                                    vertical: screenHeight * 0.02,
                                  ),
                                  child: _buildQuickSettingsIcons(screenWidth),
                                ),
                                
                                SizedBox(height: screenHeight * 0.015),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTopBar(double screenWidth) {
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    final titleSize = screenWidth < 360 ? 18.0 : 20.0;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            color: Colors.white,
            size: iconSize,
          ),
          Text(
            'Focusify',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, HomeState state, double screenWidth) {
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;
    
    return GestureDetector(
      onTap: () => _showTaskBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.radio_button_unchecked,
              color: FigmaColors.primary,
              size: screenWidth < 360 ? 20 : 24,
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Text(
                state.selectedTask ?? 'Chọn task để bắt đầu',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: state.selectedTask != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: screenWidth < 360 ? 18 : 20,
                color: Colors.grey.shade600,
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

  Widget _buildTimerSection(HomeState state, double screenWidth, double screenHeight) {
    // Responsive timer size - dựa trên chiều nhỏ nhất
    final smallestDimension = screenWidth < screenHeight ? screenWidth : screenHeight * 0.7;
    final timerSize = (smallestDimension * 0.65).clamp(220.0, 380.0);
    
    return SizedBox(
      width: timerSize,
      height: timerSize,
      child: PomodoroTimer(stateManager: _stateManager),
    );
  }

  Widget _buildPauseButton(BuildContext context, HomeState state, double screenWidth) {
    final fontSize = screenWidth < 360 ? 15.0 : 16.0;
    final buttonHeight = screenWidth < 360 ? 45.0 : 50.0;
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: () {
          if (state.isTimerRunning && !state.isPaused) {
            context.read<HomeCubit>().pauseTimer();
          } else {
            context.read<HomeCubit>().startTimer();
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: FigmaColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          state.isTimerRunning && !state.isPaused ? 'Pause' : 'Start',
          style: TextStyle(
            color: FigmaColors.primary,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSettingsIcons(double screenWidth) {
    final iconSize = screenWidth < 360 ? 24.0 : 28.0;
    final labelSize = screenWidth < 360 ? 10.0 : 11.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSettingIcon(
          icon: Icons.warning_amber_outlined,
          label: 'Strict Mode',
          iconSize: iconSize,
          labelSize: labelSize,
        ),
        _buildSettingIcon(
          icon: Icons.hourglass_empty,
          label: 'Timer Mode',
          iconSize: iconSize,
          labelSize: labelSize,
        ),
        _buildSettingIcon(
          icon: Icons.music_note_outlined,
          label: 'White Noise',
          iconSize: iconSize,
          labelSize: labelSize,
        ),
      ],
    );
  }

  Widget _buildSettingIcon({
    required IconData icon,
    required String label,
    required double iconSize,
    required double labelSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: Colors.grey.shade700,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
