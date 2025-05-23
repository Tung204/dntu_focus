import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moji_todo/features/home/presentation/strict_mode_menu.dart';
import 'package:moji_todo/features/home/presentation/timer_mode_menu.dart';
import 'package:moji_todo/features/home/presentation/white_noise_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/home_cubit.dart';
import '../domain/home_state.dart';
import 'home_screen_state_manager.dart';
import 'task_bottom_sheet.dart';
import 'widgets/pomodoro_timer.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../tasks/domain/task_cubit.dart';

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
      context.read<HomeCubit>().startTimer();
    }, (task) {
      context.read<TaskCubit>().updateTask(task.copyWith(isCompleted: true));
      final homeCubit = context.read<HomeCubit>();
      if (homeCubit.state.selectedTask == task.title) {
        homeCubit.stopTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskCubit, TaskState>(
          listener: (context, taskState) {
            final selectedTaskTitle = context.read<HomeCubit>().state.selectedTask;
            if (selectedTaskTitle != null) {
              final todayTasks = context.read<TaskCubit>().getCategorizedTasks()['Today'] ?? [];
              final isTaskStillInToday = todayTasks.any((task) => task.title == selectedTaskTitle);
              if (!isTaskStillInToday) {
                context.read<HomeCubit>().resetTask();
              }
            }
          },
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) =>
        previous.timerSeconds != current.timerSeconds ||
            previous.isTimerRunning != current.isTimerRunning ||
            previous.isPaused != current.isPaused ||
            previous.selectedTask != current.selectedTask ||
            previous.isStrictModeEnabled != current.isStrictModeEnabled ||
            previous.workDuration != current.workDuration ||
            previous.breakDuration != current.breakDuration ||
            previous.isWorkSession != current.isWorkSession ||
            previous.isWhiteNoiseEnabled != current.isWhiteNoiseEnabled ||
            previous.selectedWhiteNoise != current.selectedWhiteNoise,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              if (state.isStrictModeEnabled && state.isTimerRunning && state.isExitBlockingEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Strict Mode (Cấm thoát) đang bật! Bạn không thể thoát ứng dụng.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return false;
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const CustomAppBar(),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showTaskBottomSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.selectedTask ?? 'Select Task',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: state.selectedTask != null
                                      ? Theme.of(context).textTheme.bodyMedium?.color
                                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      PomodoroTimer(stateManager: _stateManager),
                      const SizedBox(height: 16),
                      Text(
                        'Selected Task: ${state.selectedTask ?? 'None'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const StrictModeMenu(),
                          const TimerModeMenu(),
                          const WhiteNoiseMenu(),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}