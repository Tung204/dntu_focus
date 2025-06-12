import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moji_todo/features/report/domain/report_cubit.dart';
import 'package:moji_todo/features/report/domain/report_state.dart';
import 'package:table_calendar/table_calendar.dart';

// Import các widget con
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

  // ===== SỬA LỖI: THAY THẾ GRIDVIEW BẰNG WRAP =====
  Widget _buildSummaryCards(BuildContext context, ReportState state) {
    // Lấy chiều rộng màn hình để tính toán chiều rộng cho mỗi card
    final screenWidth = MediaQuery.of(context).size.width;
    // Tổng padding ngang của màn hình là 16*2=32. Khoảng cách giữa 2 card là 16.
    // Vậy chiều rộng mỗi card = (rộng màn hình - padding - khoảng cách) / 2
    final cardWidth = (screenWidth - 32 - 16) / 2;

    final List<Widget> cards = [
      SummaryCard(
        value: _formatDuration(state.focusTimeToday),
        label: 'Focus Time Today',
      ),
      SummaryCard(
        value: _formatDuration(state.focusTimeThisWeek),
        label: 'Focus Time This Week',
      ),
      SummaryCard(
        value: _formatDuration(state.focusTimeThisTwoWeeks),
        label: 'Focus Time This Two Weeks',
      ),
      SummaryCard(
        value: _formatDuration(state.focusTimeThisMonth),
        label: 'Focus Time This Month',
      ),
    ];

    return Wrap(
      spacing: 16, // Khoảng cách theo chiều ngang
      runSpacing: 16, // Khoảng cách theo chiều dọc khi xuống dòng
      children: cards.map((card) {
        return SizedBox(
          width: cardWidth,
          child: card,
        );
      }).toList(),
    );
  }

  Widget _buildPomodoroRecords(BuildContext context, ReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Pomodoro Records',
          filterWidget: _buildFilterDropdown(
            context,
            value: ReportDataFilter.weekly,
            onChanged: (filter) {},
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PomodoroRecordsChart(
              data: state.pomodoroHeatmapData,
              allProjects: state.allProjects,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusGoal(BuildContext context, ReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Focus Time Goal',
          filterWidget: _buildFilterDropdown(
            context,
            value: ReportDataFilter.monthly,
            onChanged: (filter) {},
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: DateTime.now(),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isGoalMet = state.focusGoalMetDays.contains(DateUtils.dateOnly(day));
                  if (isGoalMet) {
                    return Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.withOpacity(0.8),
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle().copyWith(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusTimeChart(BuildContext context, ReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
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
        const SizedBox(height: 16),
        FocusTimeBarChart(
          chartData: state.focusTimeChartData,
          allProjects: state.allProjects,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, Widget? filterWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (filterWidget != null) filterWidget,
      ],
    );
  }

  Widget _buildFilterDropdown(BuildContext context,
      {required ReportDataFilter value, required void Function(ReportDataFilter?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReportDataFilter>(
          value: value,
          items: ReportDataFilter.values.map((ReportDataFilter filter) {
            final filterName = filter.name[0].toUpperCase() + filter.name.substring(1);
            return DropdownMenuItem<ReportDataFilter>(
              value: filter,
              child: Text(filterName, style: TextStyle(color: Colors.grey.shade700)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}