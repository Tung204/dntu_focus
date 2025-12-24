import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moji_todo/features/report/domain/report_state.dart';
import 'package:moji_todo/features/tasks/data/models/project_model.dart';

class FocusTimeBarChart extends StatelessWidget {
  final Map<DateTime, Map<String?, Duration>> chartData;
  final List<Project> allProjects;
  final ReportDataFilter filter;

  const FocusTimeBarChart({
    super.key,
    required this.chartData,
    required this.allProjects,
    this.filter = ReportDataFilter.weekly,
  });

  // Helper để tìm project theo ID
  Project _findProjectById(String? projectId) {
    if (projectId == null) {
      return Project(id: 'general', name: 'General', color: Colors.grey.shade400);
    }
    return allProjects.firstWhere(
          (p) => p.id == projectId,
      orElse: () => Project(id: projectId, name: 'Unknown', color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (filter) {
      case ReportDataFilter.daily:
        return _buildDailyChart(context);
      case ReportDataFilter.weekly:
        return _buildWeeklyChart(context);
      case ReportDataFilter.biweekly:
        return _buildBiweeklyChart(context);
      case ReportDataFilter.monthly:
        return _buildMonthlyChart(context);
      case ReportDataFilter.yearly:
        return _buildYearlyChart(context);
    }
  }

  /// Daily - Chi tiết theo giờ trong ngày
  Widget _buildDailyChart(BuildContext context) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final todayData = chartData[today] ?? {};
    
    // Tính tổng thời gian hôm nay
    final totalSeconds = todayData.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
    final totalHours = totalSeconds / 3600;
    
    // Phân bố theo project
    final projectDistribution = <String?, Duration>{};
    for (final entry in todayData.entries) {
      projectDistribution[entry.key] = entry.value;
    }
    
    return Column(
      children: [
        // Tổng thời gian
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: const Color(0xFFFF6B6B), size: 24),
              const SizedBox(width: 8),
              Text(
                _formatDuration(Duration(seconds: totalSeconds)),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'today',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Project breakdown
        if (projectDistribution.isNotEmpty) ...[
          Text(
            'Time by Project',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...projectDistribution.entries.map((entry) {
            final project = _findProjectById(entry.key);
            final percentage = totalSeconds > 0 
                ? entry.value.inSeconds / totalSeconds 
                : 0.0;
            return _buildProjectRow(project, entry.value, percentage);
          }),
        ] else ...[
          _buildEmptyState('No focus time recorded today'),
        ],
      ],
    );
  }

  /// Weekly - Bar chart 7 ngày (Mo-Su)
  Widget _buildWeeklyChart(BuildContext context) {
    final maxY = _calculateMaxY();
    
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: _weekdayTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY > 0 ? maxY / 4 : 1,
                getTitlesWidget: _leftTitles,
              ),
            ),
          ),
          barGroups: _getWeeklyBarGroups(),
        ),
      ),
    );
  }

  /// Biweekly - Bar chart 14 ngày
  Widget _buildBiweeklyChart(BuildContext context) {
    final maxY = _calculateMaxY();
    final sortedDates = chartData.keys.toList()..sort();
    final last14Days = sortedDates.length > 14 
        ? sortedDates.sublist(sortedDates.length - 14) 
        : sortedDates;
    
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => _dateTitles(value, meta, last14Days),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY > 0 ? maxY / 4 : 1,
                getTitlesWidget: _leftTitles,
              ),
            ),
          ),
          barGroups: _getBiweeklyBarGroups(last14Days),
        ),
      ),
    );
  }

  /// Monthly - Bar chart theo tuần hoặc tổng hợp
  Widget _buildMonthlyChart(BuildContext context) {
    final now = DateTime.now();
    final weeksData = _groupDataByWeek(now.year, now.month);
    final maxY = _calculateMonthlyMaxY(weeksData);
    
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= weeksData.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          'W${value.toInt() + 1}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxY > 0 ? maxY / 4 : 1,
                    getTitlesWidget: _leftTitles,
                  ),
                ),
              ),
              barGroups: _getMonthlyBarGroups(weeksData),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildMonthSummary(now.year, now.month),
      ],
    );
  }

  /// Yearly - Bar chart 12 tháng
  Widget _buildYearlyChart(BuildContext context) {
    final now = DateTime.now();
    final monthlyData = _groupDataByMonth(now.year);
    final maxY = _calculateYearlyMaxY(monthlyData);
    
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: _monthTitles,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: maxY > 0 ? maxY / 4 : 1,
                    getTitlesWidget: _leftTitlesHours,
                  ),
                ),
              ),
              barGroups: _getYearlyBarGroups(monthlyData),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildYearSummary(now.year),
      ],
    );
  }

  // ============ HELPER METHODS ============

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  Widget _buildProjectRow(Project project, Duration duration, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: project.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              project.name,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatDuration(duration),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ============ CHART DATA CALCULATIONS ============

  double _calculateMaxY() {
    if (chartData.isEmpty) return 4;
    double maxHours = 0;
    for (var dailyEntry in chartData.values) {
      final totalSeconds = dailyEntry.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
      final hours = totalSeconds / 3600;
      if (hours > maxHours) maxHours = hours;
    }
    return (maxHours.ceil() == 0) ? 1 : (maxHours.ceil() + 1).toDouble();
  }

  double _calculateMonthlyMaxY(List<Duration> weeksData) {
    if (weeksData.isEmpty) return 10;
    double maxHours = 0;
    for (final duration in weeksData) {
      final hours = duration.inMinutes / 60;
      if (hours > maxHours) maxHours = hours;
    }
    return (maxHours.ceil() == 0) ? 1 : (maxHours.ceil() + 5).toDouble();
  }

  double _calculateYearlyMaxY(List<Duration> monthlyData) {
    if (monthlyData.isEmpty) return 20;
    double maxHours = 0;
    for (final duration in monthlyData) {
      final hours = duration.inMinutes / 60;
      if (hours > maxHours) maxHours = hours;
    }
    return (maxHours.ceil() == 0) ? 1 : (maxHours.ceil() + 10).toDouble();
  }

  // ============ TITLE BUILDERS ============

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value % 1 != 0 || value == 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text('${value.toInt()}h', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
    );
  }

  Widget _leftTitlesHours(double value, TitleMeta meta) {
    if (value == 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text('${value.toInt()}h', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
    );
  }

  Widget _weekdayTitles(double value, TitleMeta meta) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    if (value.toInt() >= days.length) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(days[value.toInt()], style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
    );
  }

  Widget _dateTitles(double value, TitleMeta meta, List<DateTime> dates) {
    final index = value.toInt();
    if (index >= dates.length || index < 0) return const SizedBox.shrink();
    // Chỉ hiển thị một số ngày để tránh chồng chéo
    if (index % 2 != 0 && dates.length > 10) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        DateFormat('d').format(dates[index]),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
      ),
    );
  }

  Widget _monthTitles(double value, TitleMeta meta) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    if (value.toInt() >= months.length) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(months[value.toInt()], style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
    );
  }

  // ============ BAR GROUPS ============

  List<BarChartGroupData> _getWeeklyBarGroups() {
    final sortedKeys = chartData.keys.toList()..sort();
    final Map<int, Map<String?, Duration>> weeklyData = {};

    for (final date in sortedKeys) {
      final dayIndex = date.weekday - 1;
      weeklyData[dayIndex] = chartData[date]!;
    }

    return List.generate(7, (dayIndex) {
      final dailyData = weeklyData[dayIndex];
      return _createStackedBar(dayIndex, dailyData);
    });
  }

  List<BarChartGroupData> _getBiweeklyBarGroups(List<DateTime> dates) {
    return List.generate(dates.length, (index) {
      final date = dates[index];
      final dailyData = chartData[date];
      return _createStackedBar(index, dailyData, barWidth: 10);
    });
  }

  List<BarChartGroupData> _getMonthlyBarGroups(List<Duration> weeksData) {
    return List.generate(weeksData.length, (index) {
      final hours = weeksData[index].inMinutes / 60;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hours,
            color: const Color(0xFFFF6B6B),
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  List<BarChartGroupData> _getYearlyBarGroups(List<Duration> monthlyData) {
    return List.generate(12, (index) {
      final hours = index < monthlyData.length ? monthlyData[index].inMinutes / 60 : 0.0;
      final isCurrentMonth = index == DateTime.now().month - 1;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hours,
            color: isCurrentMonth ? const Color(0xFFFF6B6B) : const Color(0xFFFFB5B5),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  BarChartGroupData _createStackedBar(int x, Map<String?, Duration>? dailyData, {double barWidth = 16}) {
    double currentY = 0;
    final rodStackItems = <BarChartRodStackItem>[];

    if (dailyData != null && dailyData.isNotEmpty) {
      final sortedProjects = dailyData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedProjects) {
        final project = _findProjectById(entry.key);
        final valueInHours = entry.value.inSeconds / 3600.0;
        rodStackItems.add(
          BarChartRodStackItem(currentY, currentY + valueInHours, project.color),
        );
        currentY += valueInHours;
      }
    }

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: currentY,
          rodStackItems: rodStackItems,
          width: barWidth,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  // ============ DATA GROUPING ============

  List<Duration> _groupDataByWeek(int year, int month) {
    final weeks = <Duration>[Duration.zero, Duration.zero, Duration.zero, Duration.zero, Duration.zero];
    
    for (final entry in chartData.entries) {
      final date = entry.key;
      if (date.year == year && date.month == month) {
        final weekIndex = ((date.day - 1) / 7).floor();
        if (weekIndex < weeks.length) {
          final dayTotal = entry.value.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
          weeks[weekIndex] += Duration(seconds: dayTotal);
        }
      }
    }
    
    // Xóa tuần trống ở cuối
    while (weeks.isNotEmpty && weeks.last == Duration.zero) {
      weeks.removeLast();
    }
    
    return weeks.isEmpty ? [Duration.zero] : weeks;
  }

  List<Duration> _groupDataByMonth(int year) {
    final months = List<Duration>.filled(12, Duration.zero);
    
    for (final entry in chartData.entries) {
      final date = entry.key;
      if (date.year == year) {
        final monthIndex = date.month - 1;
        final dayTotal = entry.value.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
        months[monthIndex] += Duration(seconds: dayTotal);
      }
    }
    
    return months;
  }

  // ============ SUMMARIES ============

  Widget _buildMonthSummary(int year, int month) {
    int totalSeconds = 0;
    int activeDays = 0;
    
    for (final entry in chartData.entries) {
      if (entry.key.year == year && entry.key.month == month) {
        final dayTotal = entry.value.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
        if (dayTotal > 0) {
          totalSeconds += dayTotal;
          activeDays++;
        }
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.timer, _formatDuration(Duration(seconds: totalSeconds)), 'Total'),
          _buildStatItem(Icons.calendar_today, '$activeDays', 'Active Days'),
        ],
      ),
    );
  }

  Widget _buildYearSummary(int year) {
    int totalSeconds = 0;
    int activeDays = 0;
    
    for (final entry in chartData.entries) {
      if (entry.key.year == year) {
        final dayTotal = entry.value.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
        if (dayTotal > 0) {
          totalSeconds += dayTotal;
          activeDays++;
        }
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.timer, _formatDuration(Duration(seconds: totalSeconds)), 'Total $year'),
          _buildStatItem(Icons.calendar_today, '$activeDays', 'Active Days'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFFF6B6B)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}