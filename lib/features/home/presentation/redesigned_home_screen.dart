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

/// Home Screen redesigned theo Figma - Focusify UI Kit
/// Màu chính: Đỏ cà chua #FF6347 (255, 99, 71)
/// Font: Urbanist
class RedesignedHomeScreen extends StatefulWidget {
  const RedesignedHomeScreen({super.key});

  @override
  State<RedesignedHomeScreen> createState() => _RedesignedHomeScreenState();
}

class _RedesignedHomeScreenState extends State<RedesignedHomeScreen> with WidgetsBindingObserver {
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
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // Header với greeting
                    _buildHeader(context),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            
                            // Task Selector Card
                            _buildTaskSelector(context, state),
                            
                            const SizedBox(height: 40),
                            
                            // Pomodoro Timer - Main feature
                            PomodoroTimer(stateManager: _stateManager),
                            
                            const SizedBox(height: 32),
                            
                            // Current task indicator
                            if (state.selectedTask != null)
                              _buildCurrentTaskIndicator(state.selectedTask!),
                            
                            const SizedBox(height: 32),
                            
                            // Quick Settings Row
                            _buildQuickSettings(),
                            
                            const SizedBox(height: 40),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hãy tập trung! 🔥',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // Avatar/Profile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6347).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF6347).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFFF6347),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSelector(BuildContext context, HomeState state) {
    return GestureDetector(
      onTap: () => _showTaskBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.selectedTask != null 
                ? const Color(0xFFFF6347).withOpacity(0.3)
                : const Color(0xFFEEEEEE),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6347).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.task_alt,
                color: Color(0xFFFF6347),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedTask ?? 'Chọn task để bắt đầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: state.selectedTask != null 
                          ? const Color(0xFF212121)
                          : const Color(0xFF9E9E9E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.selectedTask != null 
                        ? 'Đang tập trung'
                        : 'Chạm để chọn task',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBDBDBD),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTaskIndicator(String taskName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6347).withOpacity(0.1),
            const Color(0xFFFF6347).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6347).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6347),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Đang focus: $taskName',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6347),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Cài đặt nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
        ),
        Row(
          children: const [
            Expanded(child: StrictModeMenu()),
            SizedBox(width: 12),
            Expanded(child: TimerModeMenu()),
            SizedBox(width: 12),
            Expanded(child: WhiteNoiseMenu()),
          ],
        ),
      ],
    );
  }
}
