import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moji_todo/features/tasks/data/models/project_model.dart';
import 'package:moji_todo/features/tasks/data/models/tag_model.dart';
import '../../../core/themes/theme.dart';
import '../../../core/constants/app_strings.dart';
import '../domain/task_cubit.dart';
import '../data/models/task_model.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task? task;

  const TaskDetailScreen({super.key, required this.task});

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return AppStrings.today;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDateOnly.isAtSameMomentAs(today)) {
      return AppStrings.today;
    } else if (dueDateOnly.isAtSameMomentAs(tomorrow)) {
      return AppStrings.tomorrow;
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 40),
        ),
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: Text(
                AppStrings.taskNotFound,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }

    final isInTrash = task!.category == 'Trash';
    final scaffoldContext = context;

    // Auto-rebuild when TaskCubit state changes
    final taskCubitState = context.watch<TaskCubit>().state;
    final List<Project> allProjects = taskCubitState.allProjects;
    final List<Tag> allTags = taskCubitState.allTags;

    String projectNameDisplay = AppStrings.noProject;
    Color projectColorDisplay = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    Project? currentProjectInstance;

    if (task!.projectId != null && task!.projectId != 'no_project_id') {
      try {
        currentProjectInstance = allProjects.firstWhere((p) => p.id == task!.projectId);
        projectNameDisplay = currentProjectInstance.name;
        projectColorDisplay = currentProjectInstance.color;
      } catch (e) {
        projectNameDisplay = '${AppStrings.projectIdPrefix} ${task!.projectId}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        title: Text(
          task!.title ?? AppStrings.untitledTask,
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
            onSelected: (value) async {
              if (value == 'Delete') {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    bool isLoading = false;
                    return StatefulBuilder( //Sử dụng StatefulBuilder cho dialog
                      builder: (alertContext, setStateDialog) { // Đổi tên setState
                        return AlertDialog(
                          title: Text(
                            isInTrash ? AppStrings.deletePermanently : AppStrings.deleteTask,
                            style: Theme.of(alertContext).textTheme.titleLarge,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isInTrash
                                    ? '${AppStrings.confirmPermanentDeleteTask} "${task!.title}"?'
                                    : '${AppStrings.task} "${task!.title}" ${AppStrings.confirmMoveToTrash}',
                                style: Theme.of(alertContext).textTheme.bodyMedium,
                              ),
                              if (isLoading) ...[
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                              child: Text(AppStrings.cancel, style: Theme.of(alertContext).textTheme.bodyMedium),
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                setStateDialog(() => isLoading = true); // Sử dụng setStateDialog
                                try {
                                  if (isInTrash) {
                                    await BlocProvider.of<TaskCubit>(scaffoldContext).deleteTask(task!);
                                  } else {
                                    await BlocProvider.of<TaskCubit>(scaffoldContext).updateTask(
                                      task!.copyWith(
                                        category: 'Trash',
                                        originalCategory: task!.category ?? 'Planned',
                                      ),
                                    );
                                  }
                                  if (!scaffoldContext.mounted) return;
                                  Navigator.pop(dialogContext);
                                  Navigator.pop(scaffoldContext, true);
                                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                    SnackBar(
                                      content: Text(isInTrash ? AppStrings.taskDeletedPermanently : AppStrings.taskMovedToTrash),
                                      backgroundColor: isInTrash
                                          ? Theme.of(scaffoldContext).colorScheme.error
                                          : Theme.of(scaffoldContext).extension<SuccessColor>()?.success ?? Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  setStateDialog(() => isLoading = false); // Sử dụng setStateDialog
                                  if (!scaffoldContext.mounted) return;
                                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                    SnackBar(content: Text('${AppStrings.errorPrefix} $e'), backgroundColor: Theme.of(scaffoldContext).colorScheme.error),
                                  );
                                }
                              },
                              child: Text(
                                isInTrash ? AppStrings.deletePermanently : AppStrings.delete,
                                style: Theme.of(alertContext).textTheme.bodyMedium?.copyWith(color: Theme.of(alertContext).colorScheme.error),
                              ),
                            ),
                            if (isInTrash)
                              TextButton(
                                onPressed: isLoading ? null : () async {
                                  setStateDialog(() => isLoading = true);
                                  try {
                                    await BlocProvider.of<TaskCubit>(scaffoldContext).updateTask(
                                        task!.copyWith(category: task!.originalCategory ?? 'Planned', originalCategory: null)
                                    );
                                    if(!scaffoldContext.mounted) return;
                                    Navigator.pop(dialogContext);
                                    Navigator.pop(scaffoldContext, true);
                                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                      SnackBar(
                                        content: Text(AppStrings.taskRestored),
                                        backgroundColor: Theme.of(scaffoldContext).extension<SuccessColor>()?.success ?? Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    setStateDialog(() => isLoading = false);
                                    if(!scaffoldContext.mounted) return;
                                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                      SnackBar(content: Text('${AppStrings.errorRestoringTask} $e'), backgroundColor: Theme.of(scaffoldContext).colorScheme.error),
                                    );
                                  }
                                },
                                child: Text(
                                  AppStrings.restore,
                                  style: Theme.of(dialogContext).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(dialogContext).extension<SuccessColor>()?.success ?? Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Delete', child: Text(isInTrash ? AppStrings.otherActionsMenu : AppStrings.delete)),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTaskDetailItem(
              context: context,
              icon: task!.isCompleted == true ? Icons.check_circle : Icons.radio_button_unchecked,
              title: AppStrings.status,
              value: task!.isCompleted == true ? AppStrings.completedStatus : AppStrings.notCompleted,
              valueColor: task!.isCompleted == true ? Theme.of(context).extension<SuccessColor>()?.success : null,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            _buildTaskDetailItem(
              context: context,
              icon: Icons.timer_outlined,
              title: AppStrings.pomodoro,
              value: '${task!.completedPomodoros ?? 0}/${task!.estimatedPomodoros ?? 0}',
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            _buildTaskDetailItem(
              context: context,
              icon: Icons.calendar_today_outlined,
              title: AppStrings.dueDate,
              value: _formatDueDate(task!.dueDate),
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            _buildTaskDetailItem(
              context: context,
              icon: Icons.flag_outlined,
              title: AppStrings.priority,
              value: task!.priority ?? AppStrings.notSet,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            _buildTaskDetailItem(
              context: context,
              icon: currentProjectInstance?.icon ?? Icons.bookmark_border,
              title: AppStrings.project,
              value: projectNameDisplay,
              valueColor: projectColorDisplay,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            _buildTaskDetailItem(
              context: context,
              icon: Icons.alarm_outlined,
              title: AppStrings.reminder,
              value: AppStrings.notSet,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            _buildTaskDetailItem(
              context: context,
              icon: Icons.repeat_outlined,
              title: AppStrings.repeat,
              value: AppStrings.none,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            const SizedBox(height: 16),

            if (task!.subtasks != null && task!.subtasks!.isNotEmpty) ...[
              Text(AppStrings.subtasks, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              ...task!.subtasks!.map((subtask) => ListTile(
                leading: Checkbox(
    value: subtask['completed'] ?? false,
    onChanged: (value) async {
    if (value == null) return;

    final updatedSubtasks = List<Map<String, dynamic>>.from(task!.subtasks!);
    final index = updatedSubtasks.indexOf(subtask);

    if (index != -1) {
    updatedSubtasks[index] = {
    ...updatedSubtasks[index],
    'completed': value,
    };

    await context.read<TaskCubit>().updateTask(
    task!.copyWith(subtasks: updatedSubtasks),
    );
    }
    }, // <— QUAN TRỌNG: dấu phẩy sau block onChanged
    shape: const CircleBorder(),
    activeColor: Theme.of(context).extension<SuccessColor>()?.success,
    ),
    title: Text(
                  subtask['title'] ?? AppStrings.untitledSubtask,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: (subtask['completed'] ?? false) ? TextDecoration.lineThrough : TextDecoration.none,
                    color: (subtask['completed'] ?? false)
                        ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              )),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton.icon(
                icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                label: Text(AppStrings.addSubtask, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                onPressed: () async {
                  final TextEditingController controller = TextEditingController();
                  final newTitle = await showDialog<String>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text(AppStrings.addSubtask),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(hintText: AppStrings.subtaskName),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(AppStrings.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
                            child: Text(AppStrings.add),
                          ),
                        ],
                      );
                    },
                  );
                  if (newTitle != null && newTitle.isNotEmpty) {
                    final updatedSubtasks = List<Map<String, dynamic>>.from(task!.subtasks ?? []);
                    updatedSubtasks.add({'title': newTitle, 'completed': false});
                    await context.read<TaskCubit>().updateTask(
                      task!.copyWith(subtasks: updatedSubtasks),
                    );
                  }
                },
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 0), alignment: Alignment.centerLeft),
              ),
            ),
            const SizedBox(height: 8),

            if (task!.tagIds != null && task!.tagIds!.isNotEmpty) ...[
              Text(AppStrings.tags, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: task!.tagIds!.map((tagId) {
                  Tag? currentTag;
                  try {
                    currentTag = allTags.firstWhere((t) => t.id == tagId);
                  } catch (e) {
                    // Tag not found, skip displaying this tag
                  }
                  if (currentTag == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      '#${currentTag.name}',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentTag.textColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            if (task!.note != null && task!.note!.isNotEmpty) ...[
              Text(AppStrings.notes, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3))),
                child: Text(task!.note!, style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 16),
            ],
            Text(AppStrings.attachments, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.attach_file, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
              title: Text(
                AppStrings.noAttachments,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to edit task screen
          print('Edit button tapped for task: ${task!.title}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.editFunctionalityNotImplemented)),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildTaskDetailItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    Color? backgroundColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color defaultTextColor = isDark ? Theme.of(context).colorScheme.onSurface : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final Color mutedTextColor = isDark ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7) : Colors.black54;
    final Color iconColor = isDark ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7) : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: defaultTextColor)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor ?? mutedTextColor, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}