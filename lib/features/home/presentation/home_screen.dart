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
              final tasksFromTaskCubit =
                  context.read<TaskCubit>().state.tasks;
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
                    content: Text(
                      'Strict Mode (Cấm thoát) đang bật! Bạn không thể thoát ứng dụng.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
                return false;
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const CustomAppBar(),
              // ===== PHẦN BODY ĐƯỢC THAY THẾ ĐỂ HẾT OVERFLOW =====
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final media = MediaQuery.of(context);
                  final screenWidth = media.size.width;
                  final screenHeight = media.size.height;
                  final viewInsetsBottom = media.viewInsets.bottom; // khi mở bàn phím

                  final double horizontalPadding =
                  screenWidth < 360 ? 16.0 : 20.0;
                  final double verticalPadding =
                  screenWidth < 360 ? 8.0 : 10.0;
                  final double selectTaskFontSize =
                  screenWidth < 360 ? 15 : 16;
                  final double selectedTaskInfoFontSize =
                  screenWidth < 360 ? 12 : 13;

                  // Giảm spacer đáy khi bàn phím mở/ màn hình thấp
                  final double bottomSpacerHeightRaw = screenHeight * 0.05;
                  final double bottomSpacerHeight = (bottomSpacerHeightRaw - viewInsetsBottom)
                      .clamp(8.0, bottomSpacerHeightRaw);

                  return SafeArea(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ==== Cụm 1: Select Task ====
                                GestureDetector(
                                  onTap: () => _showTaskBottomSheet(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardTheme.color,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.15),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow
                                              .withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.selectedTask ?? 'Chọn Task',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                              color: state.selectedTask !=
                                                  null
                                                  ? Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                                  : Theme.of(context)
                                                  .hintColor,
                                              fontSize: selectTaskFontSize,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color
                                              ?.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const Spacer(flex: 4),

                                // ==== Cụm 2: PomodoroTimer ====
                                PomodoroTimer(stateManager: _stateManager),

                                const Spacer(flex: 1),

                                // ==== Cụm 3: Text selected task ====
                                if (state.selectedTask != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0),
                                    child: Text(
                                      'Đang tập trung: ${state.selectedTask}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        fontSize: selectedTaskInfoFontSize,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                else if (screenHeight > 600)
                                  SizedBox(
                                    height:
                                    (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * 1.5 + 8.0,
                                  ),

                                // ==== Cụm 4: Hàng các Menu ====
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: screenHeight < 700
                                        ? verticalPadding / 2
                                        : verticalPadding,
                                    bottom: verticalPadding / 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: const [
                                      Flexible(child: StrictModeMenu()),
                                      Flexible(child: TimerModeMenu()),
                                      Flexible(child: WhiteNoiseMenu()),
                                    ],
                                  ),
                                ),

                                // ==== Spacer đáy đã điều chỉnh ====
                                SizedBox(height: bottomSpacerHeight),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
