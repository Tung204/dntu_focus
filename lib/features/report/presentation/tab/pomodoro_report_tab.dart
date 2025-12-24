import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moji_todo/features/report/domain/report_cubit.dart';
import 'package:moji_todo/features/report/domain/report_state.dart';
import 'package:table_calendar/table_calendar.dart';

// Import các widget con
import '../widgets/focus_goal_progress_ring.dart';
import '../widgets/focus_time_bar_chart.dart';
import '../widgets/pomodoro_records_chart.dart';
import '../widgets/summary_card.dart';

class PomodoroReportTab extends StatelessWidget {
  const PomodoroReportTab({super.key});

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    if (hours > 0) {
      result += '${hours}h ';
    }
    if (minutes > 0) {
      result += '${minutes}m';
    }
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state.status == ReportStatus.loading && state.focusTimeToday == Duration.zero) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ReportStatus.failure) {
          return Center(child: Text(state.errorMessage ?? 'Failed to load data.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(context, state),
              const SizedBox(height: 24),
              _buildPomodoroRecords(context, state),
              const SizedBox(height: 24),
              _buildFocusGoal(context, state),
              const SizedBox(height: 24),
              _buildFocusTimeChart(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReportState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                value: _formatDuration(state.focusTimeToday),
                label: 'Focus Time Today',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                value: _formatDuration(state.focusTimeThisWeek),
                label: 'Focus Time This Week',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                value: _formatDuration(state.focusTimeThisTwoWeeks),
                label: 'Focus Time This Two Weeks',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                value: _formatDuration(state.focusTimeThisMonth),
                label: 'Focus Time This Month',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPomodoroRecords(BuildContext context, ReportState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: _buildSectionHeader(
              context,
              title: 'Pomodoro Records',
              filterWidget: _buildFilterDropdown(
                context,
                value: state.pomodoroRecordsFilter,
                onChanged: (filter) {
                  if (filter != null) {
                    context.read<ReportCubit>().changePomodoroRecordsFilter(filter);
                  }
                },
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            child: PomodoroRecordsChart(
              data: state.pomodoroHeatmapData,
              allProjects: state.allProjects,
              filter: state.pomodoroRecordsFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusGoal(BuildContext context, ReportState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: _buildSectionHeader(
              context,
              title: 'Focus Time Goal',
              filterWidget: _buildFilterDropdown(
                context,
                value: state.focusGoalFilter,
                onChanged: (filter) {
                  if (filter != null) {
                    context.read<ReportCubit>().changeFocusGoalFilter(filter);
                  }
                },
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildFocusGoalContent(context, state),
          ),
        ],
      ),
    );
  }

  /// Build nội dung Focus Goal dựa theo filter
  Widget _buildFocusGoalContent(BuildContext context, ReportState state) {
    switch (state.focusGoalFilter) {
      case ReportDataFilter.daily:
        return _buildDailyFocusGoal(context, state);
      case ReportDataFilter.weekly:
        return _buildWeeklyFocusGoal(context, state);
      case ReportDataFilter.biweekly:
        return _buildBiweeklyFocusGoal(context, state);
      case ReportDataFilter.monthly:
        return _buildMonthlyFocusGoal(context, state);
      case ReportDataFilter.yearly:
        return _buildYearlyFocusGoal(context, state);
    }
  }

  /// Daily view - 1 large progress ring
  Widget _buildDailyFocusGoal(BuildContext context, ReportState state) {
    final today = DateUtils.dateOnly(DateTime.now());
    final progress = state.focusGoalProgress[today] ?? 0.0;
    final percentage = (progress * 100).toInt();
    
    return Column(
      children: [
        const SizedBox(height: 16),
        FocusGoalProgressRing(
          progress: progress,
          size: 120,
          strokeWidth: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              Text(
                progress >= 1.0 ? 'Goal Met!' : 'of goal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Today\'s Progress',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Weekly view - 7 progress rings for each day of week
  Widget _buildWeeklyFocusGoal(BuildContext context, ReportState state) {
    final now = DateTime.now();
    final weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    
    // Lấy ngày đầu tuần (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final day = DateUtils.dateOnly(startOfWeek.add(Duration(days: index)));
            final progress = state.focusGoalProgress[day] ?? 0.0;
            final isToday = DateUtils.isSameDay(day, now);
            
            return Column(
              children: [
                Text(
                  weekDays[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isToday ? const Color(0xFFFF6B6B) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                FocusGoalProgressRing(
                  progress: progress,
                  size: 36,
                  strokeWidth: 3,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? const Color(0xFFFF6B6B) : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 12),
        _buildWeekSummary(state, startOfWeek),
      ],
    );
  }

  Widget _buildWeekSummary(ReportState state, DateTime startOfWeek) {
    int goalMetDays = 0;
    for (int i = 0; i < 7; i++) {
      final day = DateUtils.dateOnly(startOfWeek.add(Duration(days: i)));
      final progress = state.focusGoalProgress[day] ?? 0.0;
      if (progress >= 1.0) goalMetDays++;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 16, color: const Color(0xFFFF6B6B)),
          const SizedBox(width: 6),
          Text(
            '$goalMetDays / 7 days goal met this week',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Biweekly view - 2 weeks of progress rings
  Widget _buildBiweeklyFocusGoal(BuildContext context, ReportState state) {
    final now = DateTime.now();
    final weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    
    // Tuần hiện tại
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    // Tuần trước
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((d) => Text(
            d,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Last week
        _buildWeekRow(state, startOfLastWeek, now, 'Last Week'),
        const SizedBox(height: 8),
        // This week
        _buildWeekRow(state, startOfThisWeek, now, 'This Week'),
      ],
    );
  }

  Widget _buildWeekRow(ReportState state, DateTime startOfWeek, DateTime now, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final day = DateUtils.dateOnly(startOfWeek.add(Duration(days: index)));
        final progress = state.focusGoalProgress[day] ?? 0.0;
        final isToday = DateUtils.isSameDay(day, now);
        
        return FocusGoalProgressRing(
          progress: progress,
          size: 32,
          strokeWidth: 2.5,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? const Color(0xFFFF6B6B) : Colors.grey.shade700,
            ),
          ),
        );
      }),
    );
  }

  /// Monthly view - Calendar with progress rings
  Widget _buildMonthlyFocusGoal(BuildContext context, ReportState state) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: DateTime.now(),
      rowHeight: 40,
      daysOfWeekHeight: 24,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        leftChevronPadding: EdgeInsets.all(8),
        rightChevronPadding: EdgeInsets.all(8),
        headerPadding: EdgeInsets.symmetric(vertical: 4),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        weekendStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.all(2),
        defaultTextStyle: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        weekendTextStyle: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        outsideTextStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dateKey = DateUtils.dateOnly(day);
          final progress = state.focusGoalProgress[dateKey] ?? 0.0;
          
          return FocusGoalCalendarCell(
            day: day.day,
            progress: progress,
            isToday: false,
            isOutside: false,
          );
        },
        outsideBuilder: (context, day, focusedDay) {
          final dateKey = DateUtils.dateOnly(day);
          final progress = state.focusGoalProgress[dateKey] ?? 0.0;
          
          return FocusGoalCalendarCell(
            day: day.day,
            progress: progress,
            isToday: false,
            isOutside: true,
          );
        },
        todayBuilder: (context, day, focusedDay) {
          final dateKey = DateUtils.dateOnly(day);
          final progress = state.focusGoalProgress[dateKey] ?? 0.0;
          
          return FocusGoalCalendarCell(
            day: day.day,
            progress: progress,
            isToday: true,
            isOutside: false,
          );
        },
      ),
    );
  }

  /// Yearly view - 12 months grid or summary
  Widget _buildYearlyFocusGoal(BuildContext context, ReportState state) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return Column(
      children: [
        // Grid of 12 months (3x4)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.9,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final monthProgress = _calculateMonthProgress(state, now.year, month);
            final isCurrentMonth = month == now.month;
            
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isCurrentMonth ? const Color(0xFFFF6B6B).withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: isCurrentMonth ? Border.all(color: const Color(0xFFFF6B6B), width: 1.5) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    months[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isCurrentMonth ? const Color(0xFFFF6B6B) : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FocusGoalProgressRing(
                    progress: monthProgress,
                    size: 26,
                    strokeWidth: 2,
                    child: Text(
                      '${(monthProgress * 100).toInt()}',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildYearSummary(state, now.year),
      ],
    );
  }

  double _calculateMonthProgress(ReportState state, int year, int month) {
    int daysWithGoal = 0;
    int totalDays = 0;
    
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateUtils.dateOnly(DateTime(year, month, day));
      if (date.isAfter(DateTime.now())) continue; // Skip future dates
      
      totalDays++;
      final progress = state.focusGoalProgress[date] ?? 0.0;
      if (progress >= 1.0) daysWithGoal++;
    }
    
    return totalDays > 0 ? daysWithGoal / totalDays : 0.0;
  }

  Widget _buildYearSummary(ReportState state, int year) {
    int totalGoalDays = 0;
    int totalActiveDays = 0;
    
    for (final entry in state.focusGoalProgress.entries) {
      if (entry.key.year == year) {
        totalActiveDays++;
        if (entry.value >= 1.0) totalGoalDays++;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 16, color: const Color(0xFFFFD700)),
          const SizedBox(width: 6),
          Text(
            '$totalGoalDays days goal met in $year',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTimeChart(BuildContext context, ReportState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: _buildSectionHeader(
              context,
              title: 'Focus Time Chart',
              filterWidget: _buildFilterDropdown(
                context,
                value: state.focusTimeChartFilter,
                onChanged: (filter) {
                  if (filter != null) {
                    context.read<ReportCubit>().changeFocusTimeChartFilter(filter);
                  }
                },
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            child: FocusTimeBarChart(
              chartData: state.focusTimeChartData,
              allProjects: state.allProjects,
              filter: state.focusTimeChartFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, Widget? filterWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (filterWidget != null) ...[
          const SizedBox(width: 8),
          filterWidget,
        ],
      ],
    );
  }

  Widget _buildFilterDropdown(BuildContext context,
      {required ReportDataFilter value, required void Function(ReportDataFilter?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReportDataFilter>(
          value: value,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade600),
          items: ReportDataFilter.values.map((ReportDataFilter filter) {
            final filterName = filter.name[0].toUpperCase() + filter.name.substring(1);
            return DropdownMenuItem<ReportDataFilter>(
              value: filter,
              child: Text(filterName, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}