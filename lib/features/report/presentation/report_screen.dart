import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moji_todo/features/report/domain/report_cubit.dart';
import 'package:moji_todo/features/report/domain/report_state.dart';
import 'package:moji_todo/features/report/presentation/tab/pomodoro_report_tab.dart';
import 'package:moji_todo/features/report/presentation/tab/tasks_report_tab.dart';
import 'package:moji_todo/features/report/presentation/widgets/custom_tab_selector.dart';
import 'package:moji_todo/features/tasks/data/models/project_tag_repository.dart';
import 'package:moji_todo/features/tasks/data/task_repository.dart';
import '../data/report_repository.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 22.0 : 26.0;
    final titleSize = screenWidth < 360 ? 18.0 : 20.0;

    // Cung cấp ReportCubit cho các widget con của nó
    return BlocProvider(
      create: (context) => ReportCubit(
        context.read<ReportRepository>(),
        context.read<ProjectTagRepository>(),
        context.read<TaskRepository>(),
      ),
      child: Scaffold(
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
            'Report',
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
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  size: iconSize,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: CustomTabSelector(
              selectedIndex: _selectedTabIndex,
              tabs: const ['Pomodoro', 'Tasks'],
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
        ),
        // Dùng BlocBuilder để lắng nghe và xây dựng lại UI theo state
        body: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            // Nếu đang tải dữ liệu lần đầu, hiển thị vòng xoay
            if (state.status == ReportStatus.loading && state.focusTimeThisWeek == Duration.zero) {
              return const Center(child: CircularProgressIndicator());
            }
            // Nếu có lỗi, hiển thị thông báo
            if (state.status == ReportStatus.failure) {
              return Center(
                  child: Text(state.errorMessage ?? 'Failed to load report data.'));
            }
            // Nếu thành công, hiển thị nội dung theo tab được chọn
            return IndexedStack(
              index: _selectedTabIndex,
              children: const [
                PomodoroReportTab(),
                TasksReportTab(),
              ],
            );
          },
        ),
      ),
    );
  }
}