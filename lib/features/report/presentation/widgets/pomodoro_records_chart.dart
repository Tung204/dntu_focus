import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moji_todo/features/report/data/models/pomodoro_session_model.dart';
import 'package:moji_todo/features/report/domain/report_state.dart';
import 'package:moji_todo/features/tasks/data/models/project_model.dart';

/// Widget hiển thị Pomodoro Records dạng lưới nhiều màu
/// Mỗi ô nhỏ đại diện cho một Pomodoro session
class PomodoroRecordsChart extends StatelessWidget {
  final Map<DateTime, List<PomodoroSessionRecordModel>> data;
  final List<Project> allProjects;
  final ReportDataFilter filter;

  const PomodoroRecordsChart({
    super.key,
    required this.data,
    required this.allProjects,
    this.filter = ReportDataFilter.weekly,
  });

  /// Lấy số ngày tối đa hiển thị dựa trên filter
  int _getMaxDaysToDisplay() {
    switch (filter) {
      case ReportDataFilter.daily:
        return 1;
      case ReportDataFilter.weekly:
        return 7;
      case ReportDataFilter.biweekly:
        return 14;
      case ReportDataFilter.monthly:
        return 30;
      case ReportDataFilter.yearly:
        return 365;
    }
  }

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
    final maxDays = _getMaxDaysToDisplay();
    
    // Với filter yearly hoặc monthly, hiển thị dạng tổng hợp
    if (filter == ReportDataFilter.yearly || filter == ReportDataFilter.monthly) {
      return _buildAggregatedView(context);
    }
    
    // Với daily, weekly, biweekly - hiển thị chi tiết theo ngày
    return _buildDetailedView(context, maxDays);
  }

  /// Build view chi tiết theo từng ngày (cho daily, weekly, biweekly)
  Widget _buildDetailedView(BuildContext context, int maxDays) {
    // Sắp xếp các ngày theo thứ tự giảm dần (mới nhất lên trên)
    final sortedDays = data.keys.toList()..sort((a, b) => b.compareTo(a));
    
    // Giới hạn hiển thị theo maxDays
    final displayDays = sortedDays.take(maxDays).toList();

    if (displayDays.isEmpty) {
      return _buildEmptyState();
    }

    // Nếu có nhiều hơn 7 ngày (biweekly), wrap trong SizedBox có giới hạn chiều cao
    final dayWidgets = displayDays.map((day) => _buildDayRow(context, day, data[day] ?? [])).toList();

    if (maxDays <= 7) {
      // Daily và Weekly - hiển thị trực tiếp
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeHeader(),
          const SizedBox(height: 8),
          ...dayWidgets,
        ],
      );
    } else {
      // Biweekly (14 ngày) - hiển thị với scroll nếu cần
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeHeader(),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: dayWidgets,
              ),
            ),
          ),
        ],
      );
    }
  }

  /// Build view tổng hợp (cho monthly, yearly)
  Widget _buildAggregatedView(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    // Tính tổng sessions và thời gian theo project
    final projectStats = <String?, int>{}; // projectId -> session count
    int totalSessions = 0;
    Duration totalDuration = Duration.zero;

    for (final dayEntry in data.entries) {
      for (final session in dayEntry.value) {
        if (session.isWorkSession) {
          totalSessions++;
          totalDuration += Duration(seconds: session.duration);
          projectStats[session.projectId] = (projectStats[session.projectId] ?? 0) + 1;
        }
      }
    }

    // Sắp xếp projects theo số sessions
    final sortedProjects = projectStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final periodLabel = filter == ReportDataFilter.monthly ? 'This Month' : 'This Year';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary row
        Row(
          children: [
            _buildStatCard(
              icon: Icons.timer_outlined,
              value: _formatDuration(totalDuration),
              label: 'Total Focus',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.check_circle_outline,
              value: '$totalSessions',
              label: 'Sessions',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.calendar_today_outlined,
              value: '${data.keys.length}',
              label: 'Active Days',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Project distribution bars
        Text(
          'Sessions by Project ($periodLabel)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedProjects.take(8).map((entry) {
          final project = _findProjectById(entry.key);
          final percentage = totalSessions > 0 ? (entry.value / totalSessions) : 0.0;
          return _buildProjectBar(project, entry.value, percentage);
        }),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFFF6B6B)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectBar(Project project, int count, double percentage) {
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
          SizedBox(
            width: 70,
            child: Text(
              project.name,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: project.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_off_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'No Pomodoro sessions recorded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    if (hours > 0) {
      result += '${hours}h ';
    }
    if (minutes > 0 || hours == 0) {
      result += '${minutes}m';
    }
    return result.trim();
  }

  /// Header hiển thị các time slots
  Widget _buildTimeHeader() {
    final timeSlots = ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'];
    
    return Row(
      children: [
        const SizedBox(width: 55), // Space cho day label
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: timeSlots.map((time) {
              return Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Mỗi hàng đại diện cho một ngày với các ô session
  Widget _buildDayRow(
    BuildContext context,
    DateTime day,
    List<PomodoroSessionRecordModel> sessions,
  ) {
    String dayLabel;
    final now = DateUtils.dateOnly(DateTime.now());
    
    if (DateUtils.isSameDay(day, now)) {
      dayLabel = 'Today';
    } else if (DateUtils.isSameDay(day, now.subtract(const Duration(days: 1)))) {
      dayLabel = 'Yester..';
    } else {
      dayLabel = DateFormat('MMM dd').format(day);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 55,
            child: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _buildSessionsHorizontalBar(sessions),
          ),
        ],
      ),
    );
  }

  /// Horizontal bar hiển thị sessions theo thời gian trong ngày
  Widget _buildSessionsHorizontalBar(List<PomodoroSessionRecordModel> sessions) {
    // Lọc chỉ lấy work sessions
    final workSessions = sessions.where((s) => s.isWorkSession).toList();
    
    if (workSessions.isEmpty) {
      return Container(
        height: 16,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    // Nhóm sessions theo giờ để tạo các ô màu
    final sessionsByTimeSlot = _groupSessionsByTimeSlot(workSessions);

    return SizedBox(
      height: 16,
      child: Row(
        children: List.generate(7, (slotIndex) {
          final sessionsInSlot = sessionsByTimeSlot[slotIndex] ?? [];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: _buildTimeSlotBar(sessionsInSlot),
            ),
          );
        }),
      ),
    );
  }

  /// Nhóm sessions theo 7 time slots
  /// Chia ngày thành 7 khoảng thời gian: 8-10h, 10-12h, 12-14h, 14-16h, 16-18h, 18-20h, 20-22h
  Map<int, List<PomodoroSessionRecordModel>> _groupSessionsByTimeSlot(
    List<PomodoroSessionRecordModel> sessions,
  ) {
    final Map<int, List<PomodoroSessionRecordModel>> grouped = {};

    for (final session in sessions) {
      final hour = session.startTime.hour;
      int slotIndex;

      if (hour >= 8 && hour < 10) {
        slotIndex = 0;
      } else if (hour >= 10 && hour < 12) {
        slotIndex = 1;
      } else if (hour >= 12 && hour < 14) {
        slotIndex = 2;
      } else if (hour >= 14 && hour < 16) {
        slotIndex = 3;
      } else if (hour >= 16 && hour < 18) {
        slotIndex = 4;
      } else if (hour >= 18 && hour < 20) {
        slotIndex = 5;
      } else if (hour >= 20 && hour < 22) {
        slotIndex = 6;
      } else {
        continue; // Skip sessions outside 8-22h
      }

      grouped.putIfAbsent(slotIndex, () => []).add(session);
    }

    return grouped;
  }

  /// Horizontal bar chứa các ô session nhỏ trong một time slot
  Widget _buildTimeSlotBar(List<PomodoroSessionRecordModel> sessions) {
    if (sessions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Hiển thị tất cả sessions trong slot dưới dạng row
    return Row(
      children: sessions.map((session) {
        final project = _findProjectById(session.projectId);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(
              color: project.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }
}