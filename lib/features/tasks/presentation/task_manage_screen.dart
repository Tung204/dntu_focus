import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/themes/design_tokens.dart';
import '../data/models/project_model.dart';
import '../data/models/project_tag_repository.dart';
import '../data/models/tag_model.dart';
import '../domain/task_cubit.dart';
import 'manage_project_and_tags/manage_projects_tags_screen.dart';
import 'widgets/task_category_card.dart';
import 'widgets/search_bar_widget.dart';
import 'add_task/add_task_bottom_sheet.dart';
import 'task_list_screen.dart';
import 'trash_screen.dart';
import 'completed_tasks_screen.dart';

class TaskManageScreen extends StatefulWidget {
  const TaskManageScreen({super.key});

  @override
  State<TaskManageScreen> createState() => _TaskManageScreenState();
}

class _TaskManageScreenState extends State<TaskManageScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Tính aspect ratio động cho grid items
  double _calculateAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 12) / 2;
    final minHeight = 85.0;
    return cardWidth / minHeight;
  }

  /// Tính aspect ratio cho compact cards (Hoàn thành, Thùng rác)
  double _calculateCompactAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 12) / 2;
    final minHeight = 50.0;
    return cardWidth / minHeight;
  }

  /// Lấy số cột dựa trên kích thước màn hình
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 40),
        ),
        child: Scaffold(
          appBar: const CustomAppBar(),
          body: Center(
            child: Text(
              'Vui lòng đăng nhập để tiếp tục.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final projectTagRepository = ProjectTagRepository(
      projectBox: Hive.box<Project>('projects'),
      tagBox: Hive.box<Tag>('tags'),
    );

    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final List<Project> allProjects = state.allProjects;
        final categorizedTasks = context.read<TaskCubit>().getCategorizedTasks();
        final tasksByProject = context.read<TaskCubit>().getTasksByProject();

        final projectBorderColors = {
          'Pomodoro App': Colors.red,
          'Fashion App': Colors.green[200]!,
          'AI Chatbot App': Colors.cyan[200]!,
          'Dating App': Colors.pink[200]!,
          'Quiz App': Colors.blue[200]!,
          'News App': Colors.blue[200]!,
          'General': Colors.blue[200]!,
          'no_project_id_display_name': Colors.grey,
        };
        final projectIcons = {
          'Pomodoro App': Icons.local_pizza_outlined,
          'Fashion App': Icons.check_box_outlined,
          'AI Chatbot App': Icons.smart_toy_outlined,
          'Dating App': Icons.favorite_outline,
          'Quiz App': Icons.quiz_outlined,
          'News App': Icons.newspaper_outlined,
          'General': Icons.category_outlined,
          'no_project_id_display_name': Icons.folder_off_outlined,
        };

        final screenWidth = MediaQuery.of(context).size.width;
        final iconSize = screenWidth < 360 ? 22.0 : 26.0;
        final titleSize = screenWidth < 360 ? 18.0 : 20.0;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: screenWidth * 0.15,
            leading: Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.05),
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).iconTheme.color,
                size: iconSize,
              ),
            ),
            title: Text(
              'Moji Focus',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.05),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).iconTheme.color,
                      size: iconSize),
                  onSelected: (value) {
                    if (value == 'Manage Projects and Tags') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageProjectsTagsScreen(
                            repository: projectTagRepository,
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Manage Projects and Tags',
                      child: Text('Quản lý Dự án và Nhãn'),
                    ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: FigmaSpacing.screenPadding.copyWith(
                  top: 0,
                  bottom: FigmaSpacing.sm,
                ),
                child: SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Tìm kiếm',
                  onChanged: (value) {
                    // TODO: Implement search filtering logic
                  },
                ),
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                // Category Cards Grid (4 cards với details)
                SliverPadding(
                  padding: FigmaSpacing.screenPadding
                      .copyWith(bottom: 0, top: FigmaSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: _calculateAspectRatio(context),
                    ),
                    delegate: SliverChildListDelegate([
                      TaskCategoryCard(
                        title: 'Hôm nay',
                        totalTime: context
                            .read<TaskCubit>()
                            .calculateTotalTime(categorizedTasks['Today'] ?? []),
                        taskCount: categorizedTasks['Today']?.length ?? 0,
                        borderColor: Colors.green,
                        icon: Icons.wb_sunny_outlined,
                        iconColor: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TaskListScreen(category: 'Today'),
                            ),
                          );
                        },
                      ),
                      TaskCategoryCard(
                        title: 'Ngày mai',
                        totalTime: context.read<TaskCubit>().calculateTotalTime(
                            categorizedTasks['Tomorrow'] ?? []),
                        taskCount: categorizedTasks['Tomorrow']?.length ?? 0,
                        borderColor: Colors.orange,
                        icon: Icons.wb_cloudy_outlined,
                        iconColor: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TaskListScreen(category: 'Tomorrow'),
                            ),
                          );
                        },
                      ),
                      TaskCategoryCard(
                        title: 'Tuần này',
                        totalTime: context.read<TaskCubit>().calculateTotalTime(
                            categorizedTasks['This Week'] ?? []),
                        taskCount: categorizedTasks['This Week']?.length ?? 0,
                        borderColor: Colors.blue,
                        icon: Icons.calendar_today_outlined,
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TaskListScreen(category: 'This Week'),
                            ),
                          );
                        },
                      ),
                      TaskCategoryCard(
                        title: 'Kế hoạch',
                        totalTime: context.read<TaskCubit>().calculateTotalTime(
                            categorizedTasks['Planned'] ?? []),
                        taskCount: categorizedTasks['Planned']?.length ?? 0,
                        borderColor: Colors.purple,
                        icon: Icons.event_note_outlined,
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TaskListScreen(category: 'Planned'),
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),

                // Compact Cards Grid (Hoàn thành, Thùng rác)
                SliverPadding(
                  padding: FigmaSpacing.screenPadding.copyWith(top: 12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: _calculateCompactAspectRatio(context),
                    ),
                    delegate: SliverChildListDelegate([
                      TaskCategoryCard(
                        title: 'Hoàn thành',
                        totalTime: '',
                        taskCount: categorizedTasks['Completed']?.length ?? 0,
                        borderColor: Colors.green[300]!,
                        icon: Icons.check_circle_outline,
                        iconColor: Colors.green[300]!,
                        showDetails: false,
                        isCompact: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompletedTasksScreen(),
                            ),
                          );
                        },
                      ),
                      TaskCategoryCard(
                        title: 'Thùng rác',
                        totalTime: '',
                        taskCount: categorizedTasks['Trash']?.length ?? 0,
                        borderColor: Colors.orange[300]!,
                        icon: Icons.delete_outline,
                        iconColor: Colors.orange[300]!,
                        showDetails: false,
                        isCompact: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrashScreen(),
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),

                // Projects Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: FigmaSpacing.screenPadding.copyWith(
                      top: FigmaSpacing.lg,
                      bottom: FigmaSpacing.md,
                    ),
                    child: Text(
                      'Dự án',
                      style: FigmaTextStyles.h3.copyWith(
                        color: isDark
                            ? FigmaColors.textOnPrimary
                            : FigmaColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // Project Cards Grid
                SliverPadding(
                  padding: FigmaSpacing.screenPadding,
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: _calculateAspectRatio(context),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final projectIdFromKey =
                            tasksByProject.keys.toList()[index];
                        String projectNameDisplay;
                        Color projectColorDisplay;
                        IconData? projectIconDisplay;
                        Project? projectModel;

                        if (projectIdFromKey == 'no_project_id') {
                          projectNameDisplay = 'Không có dự án';
                          projectColorDisplay =
                              projectBorderColors['no_project_id_display_name'] ??
                                  Colors.grey;
                          projectIconDisplay =
                              projectIcons['no_project_id_display_name'];
                        } else {
                          try {
                            projectModel = allProjects
                                .firstWhere((p) => p.id == projectIdFromKey);
                            projectNameDisplay = projectModel.name;
                            projectColorDisplay = projectModel.color;
                            projectIconDisplay = projectModel.icon;
                            projectIconDisplay ??=
                                projectIcons[projectModel.name];
                          } catch (e) {
                            debugPrint(
                                'Lỗi TaskManageScreen: Không tìm thấy project với ID: $projectIdFromKey');
                            projectNameDisplay =
                                'Dự án ID: ${projectIdFromKey.substring(0, (projectIdFromKey.length > 8) ? 8 : projectIdFromKey.length)}...';
                            projectColorDisplay = Colors.grey;
                            projectIconDisplay = Icons.folder_off_outlined;
                          }
                        }

                        return TaskCategoryCard(
                          title: projectNameDisplay,
                          totalTime: context.read<TaskCubit>().calculateTotalTime(
                              tasksByProject[projectIdFromKey]!),
                          taskCount: tasksByProject[projectIdFromKey]!.length,
                          borderColor: projectColorDisplay,
                          icon: projectIconDisplay,
                          iconColor: projectColorDisplay,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskListScreen(
                                  category: 'project',
                                  filterId: projectIdFromKey == 'no_project_id'
                                      ? null
                                      : projectIdFromKey,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: tasksByProject.length,
                    ),
                  ),
                ),

                // Bottom spacing for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'tasks_fab_manage_screen',
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            onPressed: () {
              debugPrint('FAB pressed - showing AddTaskBottomSheet');
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                builder: (bottomSheetContext) {
                  debugPrint('Building AddTaskBottomSheet');
                  return BlocProvider.value(
                    value: context.read<TaskCubit>(),
                    child: AddTaskBottomSheet(
                      repository: projectTagRepository,
                    ),
                  );
                },
              );
            },
            child: Icon(
              Icons.add,
              color:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
            ),
          ),
        );
      },
    );
  }
}
