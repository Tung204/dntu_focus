import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moji_todo/features/report/data/models/pomodoro_session_model.dart';
import 'package:moji_todo/features/tasks/data/models/project_model.dart';

/// Service để tạo dữ liệu mẫu cho màn hình Report
/// Dùng để test UI design với dữ liệu đa dạng
class MockDataGenerator {
  final Random _random = Random();

  /// Danh sách màu sắc đa dạng cho projects
  static const List<Color> projectColors = [
    Color(0xFFFF6B6B), // Đỏ
    Color(0xFFFFD93D), // Vàng
    Color(0xFF6BCF7F), // Xanh lá
    Color(0xFF4ECDC4), // Xanh dương
    Color(0xFF95E1D3), // Xanh mint
    Color(0xFFFFA07A), // Cam nhạt
    Color(0xFFB388EB), // Tím
    Color(0xFFFF85C1), // Hồng
    Color(0xFFFF9999), // Đỏ nhạt
    Color(0xFFFFCC99), // Cam nhạt hơn
  ];

  /// Tạo danh sách projects mẫu với màu sắc đa dạng
  List<Project> generateMockProjects() {
    return [
      Project(
        id: 'mock_p1',
        name: 'Work Project',
        color: projectColors[0],
      ),
      Project(
        id: 'mock_p2',
        name: 'Study',
        color: projectColors[1],
      ),
      Project(
        id: 'mock_p3',
        name: 'Exercise',
        color: projectColors[2],
      ),
      Project(
        id: 'mock_p4',
        name: 'Reading',
        color: projectColors[3],
      ),
      Project(
        id: 'mock_p5',
        name: 'Coding',
        color: projectColors[4],
      ),
      Project(
        id: 'mock_p6',
        name: 'Writing',
        color: projectColors[5],
      ),
      Project(
        id: 'mock_p7',
        name: 'Music',
        color: projectColors[6],
      ),
      Project(
        id: 'mock_p8',
        name: 'Art',
        color: projectColors[7],
      ),
    ];
  }

  /// Tạo Pomodoro sessions mẫu cho một khoảng thời gian
  /// [days] - số ngày muốn tạo dữ liệu (mặc định 14)
  List<PomodoroSessionRecordModel> generateMockPomodoroSessions({
    int days = 14,
    List<Project>? projects,
  }) {
    final mockProjects = projects ?? generateMockProjects();
    final sessions = <PomodoroSessionRecordModel>[];
    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < days; dayOffset++) {
      final date = now.subtract(Duration(days: dayOffset));
      
      // Mỗi ngày có 4-8 sessions ngẫu nhiên
      final sessionsPerDay = 4 + _random.nextInt(5);
      
      for (int i = 0; i < sessionsPerDay; i++) {
        // Thời gian trong ngày: 8:00 - 20:00
        final hour = 8 + _random.nextInt(12);
        final minute = _random.nextInt(60);
        
        final startTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        
        // Duration: 25 phút (1 Pomodoro) hoặc 50 phút (2 Pomodoro)
        final durationMinutes = _random.nextBool() ? 25 : 50;
        final endTime = startTime.add(Duration(minutes: durationMinutes));
        
        // Random project
        final project = mockProjects[_random.nextInt(mockProjects.length)];
        
        sessions.add(
          PomodoroSessionRecordModel(
            id: 'mock_session_${dayOffset}_$i',
            userId: 'mock_user',
            startTime: startTime,
            endTime: endTime,
            duration: durationMinutes * 60, // Convert to seconds
            isWorkSession: true,
            projectId: project.id,
            taskId: null, // Có thể thêm taskId nếu cần
          ),
        );
      }
    }

    // Sắp xếp sessions theo thời gian
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    return sessions;
  }

  /// Tạo dữ liệu mẫu cho Focus Time theo từng khoảng thời gian
  Map<String, Duration> generateMockFocusTimeStats() {
    return {
      'today': const Duration(hours: 2, minutes: 5),
      'thisWeek': const Duration(hours: 39, minutes: 35),
      'thisTwoWeeks': const Duration(hours: 79, minutes: 10),
      'thisMonth': const Duration(hours: 160, minutes: 25),
      'thisYear': const Duration(hours: 450, minutes: 30),
    };
  }

  /// Tạo dữ liệu mẫu cho tasks completed
  Map<String, int> generateMockTasksCompletedStats() {
    return {
      'today': 3,
      'thisWeek': 18,
      'thisTwoWeeks': 35,
      'thisMonth': 72,
      'thisYear': 350,
    };
  }

  /// Tạo các ngày đạt mục tiêu focus time (cho calendar)
  Set<DateTime> generateMockGoalMetDays({int days = 30}) {
    final goalDays = <DateTime>{};
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      // Khoảng 60% các ngày đạt mục tiêu
      if (_random.nextDouble() < 0.6) {
        final date = now.subtract(Duration(days: i));
        goalDays.add(DateUtils.dateOnly(date));
      }
    }
    
    return goalDays;
  }

  /// Tạo progress data cho Focus Goal (0.0 - 1.0)
  /// Mỗi ngày có một progress tương ứng với % hoàn thành mục tiêu
  Map<DateTime, double> generateMockFocusGoalProgress({int days = 60}) {
    final progressData = <DateTime, double>{};
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = DateUtils.dateOnly(now.subtract(Duration(days: i)));
      
      // Random progress từ 0.0 đến 1.2 (có thể vượt mục tiêu)
      // Nhưng clamp lại 0-1 để hiển thị
      final rawProgress = _random.nextDouble() * 1.3;
      
      // 30% chance không có data (ngày nghỉ)
      if (_random.nextDouble() > 0.3) {
        progressData[date] = rawProgress.clamp(0.0, 1.0);
      }
    }
    
    return progressData;
  }

  /// Tạo dữ liệu chart theo ngày (cho Focus Time Chart)
  Map<DateTime, Map<String?, Duration>> generateMockFocusTimeChartData({
    int days = 14,
    List<Project>? projects,
  }) {
    final mockProjects = projects ?? generateMockProjects();
    final chartData = <DateTime, Map<String?, Duration>>{};
    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < days; dayOffset++) {
      final date = DateUtils.dateOnly(now.subtract(Duration(days: dayOffset)));
      final dailyData = <String?, Duration>{};

      // Mỗi ngày có 2-5 projects với thời gian khác nhau
      final projectsPerDay = 2 + _random.nextInt(4);
      final usedProjects = <Project>[];
      
      for (int i = 0; i < projectsPerDay; i++) {
        Project project;
        do {
          project = mockProjects[_random.nextInt(mockProjects.length)];
        } while (usedProjects.contains(project) && usedProjects.length < mockProjects.length);
        
        usedProjects.add(project);
        
        // Thời gian cho mỗi project: 30 phút - 3 giờ
        final minutes = 30 + _random.nextInt(151);
        dailyData[project.id] = Duration(minutes: minutes);
      }

      chartData[date] = dailyData;
    }

    return chartData;
  }

  /// Tạo dữ liệu heatmap (sessions theo ngày)
  Map<DateTime, List<PomodoroSessionRecordModel>> generateMockHeatmapData({
    int days = 14,
    List<Project>? projects,
  }) {
    final sessions = generateMockPomodoroSessions(days: days, projects: projects);
    final heatmapData = <DateTime, List<PomodoroSessionRecordModel>>{};

    for (final session in sessions) {
      final day = DateUtils.dateOnly(session.startTime);
      heatmapData.putIfAbsent(day, () => []).add(session);
    }

    return heatmapData;
  }

  /// Tính tổng focus time từ danh sách sessions
  Duration calculateTotalFocusTime(List<PomodoroSessionRecordModel> sessions) {
    final totalSeconds = sessions
        .where((s) => s.isWorkSession)
        .fold<int>(0, (sum, s) => sum + s.duration);
    return Duration(seconds: totalSeconds);
  }

  /// Tạo distribution của project time
  Map<String?, Duration> generateMockProjectDistribution({
    List<Project>? projects,
  }) {
    final mockProjects = projects ?? generateMockProjects();
    final distribution = <String?, Duration>{};

    for (final project in mockProjects) {
      // Mỗi project có 1-10 giờ
      final hours = 1 + _random.nextInt(10);
      final minutes = _random.nextInt(60);
      distribution[project.id] = Duration(hours: hours, minutes: minutes);
    }

    return distribution;
  }
}