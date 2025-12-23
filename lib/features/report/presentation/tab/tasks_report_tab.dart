import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Mock data cho Tasks Report Tab - phù hợp với database structure
class _MockData {
  // Task completion stats theo filter
  static Map<String, Map<String, int>> get taskCompletionStats => {
    'Daily': {'completed': 3, 'total': 8, 'high': 1, 'medium': 1, 'low': 1},
    'Weekly': {'completed': 18, 'total': 32, 'high': 5, 'medium': 8, 'low': 5},
    'Biweekly': {'completed': 35, 'total': 58, 'high': 10, 'medium': 15, 'low': 10},
    'Monthly': {'completed': 72, 'total': 105, 'high': 20, 'medium': 32, 'low': 20},
    'Yearly': {'completed': 458, 'total': 620, 'high': 120, 'medium': 218, 'low': 120},
  };

  // Project focus time data (từ PomodoroSession) - giả lập data real
  static List<Map<String, dynamic>> get projectFocusTime => [
    {
      'id': 'proj_1',
      'name': 'Pomodoro App',
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.timer,
      'focusMinutes': 485, // 8h 5m
      'taskCount': 12,
      'completedTasks': 8,
    },
    {
      'id': 'proj_2', 
      'name': 'Flight App',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.flight,
      'focusMinutes': 370, // 6h 10m
      'taskCount': 8,
      'completedTasks': 5,
    },
    {
      'id': 'proj_3',
      'name': 'Work Project',
      'color': const Color(0xFFFFB800),
      'icon': Icons.work,
      'focusMinutes': 288, // 4h 48m
      'taskCount': 15,
      'completedTasks': 10,
    },
    {
      'id': 'proj_4',
      'name': 'Dating App',
      'color': const Color(0xFFFF69B4),
      'icon': Icons.favorite,
      'focusMinutes': 250, // 4h 10m
      'taskCount': 6,
      'completedTasks': 4,
    },
    {
      'id': 'proj_5',
      'name': 'AI Chatbot',
      'color': const Color(0xFF10B981),
      'icon': Icons.smart_toy,
      'focusMinutes': 192, // 3h 12m
      'taskCount': 9,
      'completedTasks': 7,
    },
    {
      'id': 'no_project',
      'name': 'No Project',
      'color': Colors.grey,
      'icon': Icons.folder_off,
      'focusMinutes': 915, // 15h 15m - tasks không có project
      'taskCount': 20,
      'completedTasks': 15,
    },
  ];

  // Focus time by individual tasks (top tasks)
  static List<Map<String, dynamic>> get topTasksByFocusTime => [
    {'name': 'UI/UX Design Research', 'focusMinutes': 445, 'projectName': 'Pomodoro App', 'color': const Color(0xFFFF6B6B), 'isCompleted': true},
    {'name': 'Design User Interface (UI)', 'focusMinutes': 410, 'projectName': 'Flight App', 'color': const Color(0xFF3B82F6), 'isCompleted': true},
    {'name': 'Create a Design Wireframe', 'focusMinutes': 340, 'projectName': 'Work Project', 'color': const Color(0xFFFFB800), 'isCompleted': false},
    {'name': 'Market Research and Analysis', 'focusMinutes': 280, 'projectName': 'Dating App', 'color': const Color(0xFFFF69B4), 'isCompleted': true},
    {'name': 'Write a Report & Proposal', 'focusMinutes': 270, 'projectName': 'AI Chatbot', 'color': const Color(0xFF10B981), 'isCompleted': false},
    {'name': 'Write a Research Paper', 'focusMinutes': 255, 'projectName': 'No Project', 'color': Colors.grey, 'isCompleted': true},
    {'name': 'Read Articles', 'focusMinutes': 220, 'projectName': 'Pomodoro App', 'color': const Color(0xFFFF6B6B), 'isCompleted': false},
  ];

  // Task chart data (tasks completed per day)
  static List<Map<String, dynamic>> get taskChartData => [
    {'day': '9', 'completed': 3, 'pending': 2},
    {'day': '10', 'completed': 4, 'pending': 1},
    {'day': '11', 'completed': 2, 'pending': 3},
    {'day': '12', 'completed': 5, 'pending': 1},
    {'day': '13', 'completed': 4, 'pending': 2},
    {'day': '14', 'completed': 6, 'pending': 0},
    {'day': '15', 'completed': 3, 'pending': 2},
    {'day': '16', 'completed': 4, 'pending': 1},
    {'day': '17', 'completed': 5, 'pending': 2},
    {'day': '18', 'completed': 2, 'pending': 3},
    {'day': '19', 'completed': 4, 'pending': 1},
    {'day': '20', 'completed': 3, 'pending': 2},
    {'day': '21', 'completed': 6, 'pending': 1},
    {'day': '22', 'completed': 4, 'pending': 2},
  ];
}

class TasksReportTab extends StatefulWidget {
  const TasksReportTab({super.key});

  @override
  State<TasksReportTab> createState() => _TasksReportTabState();
}

class _TasksReportTabState extends State<TasksReportTab> {
  String _taskCompletionFilter = 'Weekly';
  String _projectFocusFilter = 'Weekly';
  String _focusTimeFilter = 'Tasks'; // Tasks or Projects
  String _taskChartFilter = 'Biweekly';

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context),
          const SizedBox(height: 24),
          _buildTaskCompletionOverview(context),
          const SizedBox(height: 24),
          _buildProjectFocusTimeSection(context),
          const SizedBox(height: 24),
          _buildFocusTimeSection(context),
          const SizedBox(height: 24),
          _buildTaskChartSection(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ========== SUMMARY CARDS (4 ô thống kê) ==========
  Widget _buildSummaryCards(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final stats = _MockData.taskCompletionStats;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                value: stats['Daily']!['completed'].toString(),
                label: 'Task Completed Today',
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                value: stats['Weekly']!['completed'].toString(),
                label: 'Task Completed This Week',
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                value: stats['Biweekly']!['completed'].toString(),
                label: 'Task Completed This Two...',
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                value: stats['Monthly']!['completed'].toString(),
                label: 'Task Completed This Month',
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String value,
    required String label,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6B6B),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ========== 1. TASK COMPLETION OVERVIEW ==========
  Widget _buildTaskCompletionOverview(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final stats = _MockData.taskCompletionStats[_taskCompletionFilter]!;
    final completed = stats['completed']!;
    final total = stats['total']!;
    final pending = total - completed;
    final progress = total > 0 ? completed / total : 0.0;
    final highPriority = stats['high']!;
    final mediumPriority = stats['medium']!;
    final lowPriority = stats['low']!;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSectionHeaderInCard(
              context,
              title: 'Task Completion',
              filterValue: _taskCompletionFilter,
              filterOptions: const ['Daily', 'Weekly', 'Biweekly', 'Monthly', 'Yearly'],
              onFilterChanged: (value) {
                setState(() => _taskCompletionFilter = value);
              },
              isDarkMode: isDarkMode,
            ),
          ),
          Divider(height: 1, color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress circle with stats
                Row(
                  children: [
                    // Circular progress
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Stats
                    Expanded(
                      child: Column(
                        children: [
                          _buildCompletionStatRow(
                            'Completed',
                            completed.toString(),
                            const Color(0xFF10B981),
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildCompletionStatRow(
                            'Pending',
                            pending.toString(),
                            const Color(0xFFFF6B6B),
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildCompletionStatRow(
                            'Total',
                            total.toString(),
                            const Color(0xFF3B82F6),
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Priority breakdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPriorityBadge('High', highPriority, const Color(0xFFFF6B6B), isDarkMode),
                      _buildPriorityBadge('Medium', mediumPriority, const Color(0xFFFFB800), isDarkMode),
                      _buildPriorityBadge('Low', lowPriority, const Color(0xFF10B981), isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStatRow(String label, String value, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String label, int count, Color color, bool isDarkMode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ========== 2. PROJECT FOCUS TIME SECTION ==========
  Widget _buildProjectFocusTimeSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final projects = _MockData.projectFocusTime;
    final totalMinutes = projects.fold<int>(0, (sum, p) => sum + (p['focusMinutes'] as int));

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSectionHeaderInCard(
              context,
              title: 'Project Focus Time',
              filterValue: _projectFocusFilter,
              filterOptions: const ['Daily', 'Weekly', 'Biweekly', 'Monthly', 'Yearly'],
              onFilterChanged: (value) {
                setState(() => _projectFocusFilter = value);
              },
              isDarkMode: isDarkMode,
            ),
          ),
          Divider(height: 1, color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Donut chart
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 55,
                          sections: projects.map((project) {
                            final minutes = project['focusMinutes'] as int;
                            final percent = totalMinutes > 0 ? minutes / totalMinutes * 100 : 0.0;
                            return PieChartSectionData(
                              value: percent,
                              color: project['color'] as Color,
                              radius: 30,
                              showTitle: false,
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMinutes(totalMinutes),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Project list
                ...projects.map((project) => _buildProjectFocusItem(
                  context,
                  project: project,
                  totalMinutes: totalMinutes,
                  isDarkMode: isDarkMode,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectFocusItem(
    BuildContext context, {
    required Map<String, dynamic> project,
    required int totalMinutes,
    required bool isDarkMode,
  }) {
    final color = project['color'] as Color;
    final focusMinutes = project['focusMinutes'] as int;
    final percent = totalMinutes > 0 ? (focusMinutes / totalMinutes * 100) : 0.0;
    final taskCount = project['taskCount'] as int;
    final completedTasks = project['completedTasks'] as int;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Project icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              project['icon'] as IconData,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          // Project info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completedTasks/$taskCount tasks',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Focus time & percent
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatMinutes(focusMinutes),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== 3. FOCUS TIME BY TASKS/PROJECTS ==========
  Widget _buildFocusTimeSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tasks = _MockData.topTasksByFocusTime;
    final maxMinutes = tasks.first['focusMinutes'] as int;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSectionHeaderInCard(
              context,
              title: 'Top Tasks by Focus Time',
              filterValue: _focusTimeFilter,
              filterOptions: const ['Tasks', 'Projects'],
              onFilterChanged: (value) {
                setState(() => _focusTimeFilter = value);
              },
              isDarkMode: isDarkMode,
            ),
          ),
          Divider(height: 1, color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final focusMinutes = task['focusMinutes'] as int;
              final progress = focusMinutes / maxMinutes;
              final color = task['color'] as Color;
              final isCompleted = task['isCompleted'] as bool;
              
              return _buildTopTaskItem(
                context,
                name: task['name'] as String,
                projectName: task['projectName'] as String,
                focusMinutes: focusMinutes,
                progress: progress,
                color: color,
                isCompleted: isCompleted,
                isDarkMode: isDarkMode,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopTaskItem(
    BuildContext context, {
    required String name,
    required String projectName,
    required int focusMinutes,
    required double progress,
    required Color color,
    required bool isCompleted,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Status indicator
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isCompleted ? const Color(0xFF10B981) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    projectName,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatMinutes(focusMinutes),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ========== 4. TASK CHART SECTION ==========
  Widget _buildTaskChartSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSectionHeaderInCard(
              context,
              title: 'Task Completion Trend',
              filterValue: _taskChartFilter,
              filterOptions: const ['Weekly', 'Biweekly', 'Monthly', 'Yearly'],
              onFilterChanged: (value) {
                setState(() => _taskChartFilter = value);
              },
              isDarkMode: isDarkMode,
            ),
          ),
          Divider(height: 1, color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTaskCompletionChart(context, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCompletionChart(BuildContext context, bool isDarkMode) {
    final data = _MockData.taskChartData;
    final maxValue = data.fold<int>(0, (max, d) {
      final completed = d['completed'] as int;
      final pending = d['pending'] as int;
      return (completed + pending) > max ? (completed + pending) : max;
    });

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Completed', const Color(0xFF10B981), isDarkMode),
            const SizedBox(width: 24),
            _buildLegendItem('Pending', const Color(0xFFFF6B6B), isDarkMode),
          ],
        ),
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue.toDouble() + 2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[index]['day'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value % 2 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((entry) {
                final index = entry.key;
                final dayData = entry.value;
                final completed = (dayData['completed'] as int).toDouble();
                final pending = (dayData['pending'] as int).toDouble();

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: completed + pending,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      rodStackItems: [
                        BarChartRodStackItem(0, completed, const Color(0xFF10B981)),
                        BarChartRodStackItem(completed, completed + pending, const Color(0xFFFF6B6B)),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ========== COMMON WIDGETS ==========
  Widget _buildSectionHeaderInCard(
    BuildContext context, {
    required String title,
    required String filterValue,
    required List<String> filterOptions,
    required ValueChanged<String> onFilterChanged,
    required bool isDarkMode,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filterValue,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
              items: filterOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onFilterChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String filterValue,
    required List<String> filterOptions,
    required ValueChanged<String> onFilterChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filterValue,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
              items: filterOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onFilterChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}