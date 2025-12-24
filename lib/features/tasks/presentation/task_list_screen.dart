import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:moji_todo/core/constants/app_strings.dart';
import 'package:moji_todo/features/tasks/data/models/project_model.dart';
import 'package:moji_todo/features/tasks/presentation/widgets/task_item_card.dart';
import '../domain/task_cubit.dart';
import '../data/models/project_tag_repository.dart';
import '../data/models/tag_model.dart';
import '../data/models/task_model.dart';
import 'task_detail_screen.dart';
import 'add_task/add_task_bottom_sheet.dart';
// import 'package:collection/collection.dart'; // Uncomment if using firstWhereOrNull

class TaskListScreen extends StatelessWidget {
  final String category;
  final String? filterId; // Will be projectId if category == 'project'

  const TaskListScreen({
    super.key,
    required this.category,
    this.filterId,
  });

  @override
  Widget build(BuildContext context) {
    final projectTagRepository = ProjectTagRepository(
      projectBox: Hive.box<Project>('projects'),
      tagBox: Hive.box<Tag>('tags'),
    );

    // Listen to TaskState to get data and rebuild when needed
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        // Get allProjects from state to lookup project name
        final List<Project> allProjects = state.allProjects;
        String screenTitle = category; // Default title

        List<Task> tasksToDisplay;

        if (category == 'project') {
          if (filterId != null && filterId != 'no_project_id') {
            tasksToDisplay = state.tasks
                .where((task) =>
            task.projectId == filterId &&
                task.userId == FirebaseAuth.instance.currentUser?.uid &&
                task.category != 'Trash')
                .toList();
            try {
              // final project = allProjects.firstWhereOrNull((p) => p.id == filterId); // Use firstWhereOrNull from package:collection
              final project = allProjects.firstWhere((p) => p.id == filterId);
              screenTitle = project.name;
            } catch (e) {
              print('TaskListScreen: ${AppStrings.projectNotFoundMessage}: $filterId');
              screenTitle = AppStrings.projectNotFound;
            }
          } else if (filterId == null || filterId == 'no_project_id') { // Handle case where task has no project
            tasksToDisplay = state.tasks
                .where((task) =>
            (task.projectId == null || task.projectId == 'no_project_id') &&
                task.userId == FirebaseAuth.instance.currentUser?.uid &&
                task.category != 'Trash')
                .toList();
            screenTitle = AppStrings.noProject;
          }
          else {
            // Case where category is 'project' but filterId is null (shouldn't happen if navigation is correct)
            tasksToDisplay = [];
            screenTitle = AppStrings.undefinedProject;
          }
        } else {
          // Filter by category as before (Today, Tomorrow, This Week, Planned)
          final categorizedTasks = context.read<TaskCubit>().getCategorizedTasks();
          tasksToDisplay = categorizedTasks[category] ?? [];
          // Update screenTitle for common categories
          if (category == 'Today') {
            screenTitle = AppStrings.today;
          } else if (category == 'Tomorrow') screenTitle = AppStrings.tomorrow;
          else if (category == 'This Week') screenTitle = AppStrings.thisWeek;
          else if (category == 'Planned') screenTitle = AppStrings.planned;
          // Keep `category` as title if it doesn't match the above cases
        }

        if (state.isLoading && tasksToDisplay.isEmpty) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 40), // Add extra padding at top
            ),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(screenTitle, style: Theme.of(context).textTheme.titleLarge),
                centerTitle: true,
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final completedTasks = tasksToDisplay.where((task) => task.isCompleted == true).toList();
        final waitingTasks = tasksToDisplay.where((task) => task.isCompleted != true).toList();

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 40), // Add extra padding at top
          ),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                screenTitle, // Use the determined screenTitle
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        final TextEditingController controller = TextEditingController();
                        return AlertDialog(
                          title: Text(
                            '${AppStrings.searchIn} "$screenTitle"',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: AppStrings.enterTaskName,
                              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(AppStrings.cancel, style: Theme.of(context).textTheme.bodyMedium),
                            ),
                            TextButton(
                              onPressed: () async {
                                // searchTasks will search on all state.tasks
                                // Then TaskListScreen will automatically rebuild and filter tasksToDisplay again
                                await context.read<TaskCubit>().searchTasks(controller.text);
                                Navigator.pop(dialogContext);
                              },
                              child: Text(AppStrings.searchButton, style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // sortTasks will sort state.tasks, then TaskListScreen will rebuild and filter again
                    if (value == AppStrings.sortByDueDate) {
                      context.read<TaskCubit>().sortTasks('dueDate');
                    } else if (value == AppStrings.sortByPriority) {
                      context.read<TaskCubit>().sortTasks('priority');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: AppStrings.sortByDueDate, child: Text(AppStrings.sortByDueDate)),
                    PopupMenuItem(value: AppStrings.sortByPriority, child: Text(AppStrings.sortByPriority)),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary information display section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.read<TaskCubit>().calculateTotalTime(tasksToDisplay).toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.totalEstimatedTime,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.read<TaskCubit>().calculateElapsedTime(tasksToDisplay).toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.completedTime,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                waitingTasks.length.toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.pendingTasks,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                completedTasks.length.toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.completedTasks,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // "Add a task" button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                          ),
                          builder: (_) => BlocProvider.value(
                            value: context.read<TaskCubit>(), // Provide current TaskCubit
                            child: AddTaskBottomSheet(
                              repository: projectTagRepository,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.addATask,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: tasksToDisplay.isEmpty
                        ? Center(
                      child: Text(
                        '${AppStrings.noTasks} "$screenTitle".',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                        : ListView.builder(
                      itemCount: waitingTasks.length + (completedTasks.isNotEmpty ? 1 : 0) + completedTasks.length,
                      itemBuilder: (context, index) {
                        // TaskItemCard will need to access allProjects and allTags from TaskState
                        // to display project/tag names from IDs.
                        // Best way is for TaskItemCard to do this itself using context.read<TaskCubit>().state
                        if (index < waitingTasks.length) {
                          final task = waitingTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TaskItemCard(
                              task: task,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<TaskCubit>(),
                                      child: TaskDetailScreen(task: task),
                                    ),
                                  ),
                                ).then((value) {if (value == true) context.read<TaskCubit>().loadInitialData();});
                              },
                              onCheckboxChanged: (value) {
                                if (value != null) {
                                  context.read<TaskCubit>().updateTask(task.copyWith(isCompleted: value));
                                }
                              },
                              onPlayPressed: () { /* Pomodoro Logic */ },
                              showDetails: true,
                            ),
                          );
                        } else if (index == waitingTasks.length && completedTasks.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              '${AppStrings.completed} (${completedTasks.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        } else if (completedTasks.isNotEmpty) {
                          final completedIndex = index - waitingTasks.length - (completedTasks.isNotEmpty ? 1 : 0);
                          if (completedIndex < 0 || completedIndex >= completedTasks.length) {
                            return const SizedBox.shrink();
                          }
                          final task = completedTasks[completedIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TaskItemCard(
                              task: task,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<TaskCubit>(),
                                      child: TaskDetailScreen(task: task),
                                    ),
                                  ),
                                ).then((value) {if (value == true) context.read<TaskCubit>().loadInitialData();});
                              },
                              onCheckboxChanged: (value) {
                                if (value != null) {
                                  context.read<TaskCubit>().updateTask(task.copyWith(isCompleted: value));
                                }
                              },
                              onPlayPressed: () { /* Pomodoro Logic */ },
                              showDetails: true,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'task_list_screen_fab', // Ensure heroTag is unique
              backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  builder: (_) => BlocProvider.value(
                    value: context.read<TaskCubit>(),
                    child: AddTaskBottomSheet(
                      repository: projectTagRepository,
                    ),
                  ),
                );
              },
              child: Icon(Icons.add, color: Theme.of(context).floatingActionButtonTheme.foregroundColor),
            ),
          ),
        );
      },
    );
  }
}