# Kế Hoạch Thiết Kế Lại Màn Hình Report (Tab Pomodoro)

## 📋 Tổng Quan

Thiết kế lại tab Pomodoro của màn hình Report theo đúng thiết kế từ ảnh tham khảo, bao gồm:
- 4 Summary Cards hiển thị thống kê thời gian tập trung
- Pomodoro Records Chart dạng lưới nhiều màu
- Focus Time Goal Calendar với các ngày đạt mục tiêu
- Focus Time Chart dạng biểu đồ cột nhiều màu

## 🎨 Phân Tích Thiết Kế Từ Ảnh

### 1. **Summary Cards** (4 cards ở đầu)
- **Layout**: 2 cột x 2 hàng
- **Màu sắc**: 
  - Background: Màu coral/đỏ nhạt (#FFE5E5 hoặc tương tự)
  - Text giá trị: Màu đỏ đậm/coral (#FF6B6B)
  - Text label: Màu xám
- **Nội dung**:
  - Card 1: "2h 5m" - "Focus Time Today"
  - Card 2: "39h 35m" - "Focus Time This Week"
  - Card 3: "79h 10m" - "Focus Time This Two Weeks"
  - Card 4: "160h 25m" - "Focus Time This Month"

### 2. **Pomodoro Records** (Lưới nhiều màu)
- **Layout**: Lưới dạng bảng
  - Cột ngang: Thời gian (18:00, 9:00, 4:00, 6:00, 8:00, 10:00, 20:00)
  - Hàng dọc: Các ngày (Today, Dec 19, Dec 18, Dec 17, Dec 16, Dec 15, Dec 14)
- **Màu sắc**: Mỗi ô có nhiều màu khác nhau (đỏ, vàng, xanh lá, xanh dương, tím, cam, hồng)
  - Các màu sáng rực rỡ
  - Mỗi ô nhỏ đại diện cho một Pomodoro session
- **Filter**: Dropdown "Weekly" ở góc phải

### 3. **Focus Time Goal** (Calendar)
- **Layout**: Calendar tháng (December 2023)
- **Màu sắc**:
  - Ngày đạt mục tiêu: Vòng tròn đỏ bao quanh số ngày
  - Ngày thường: Không có vòng tròn
- **Các ngày được đánh dấu**: 1, 3, 4, 5, 8, 11, 13, 15, 17 (có vòng tròn đỏ)
- **Filter**: Dropdown "Monthly"

### 4. **Focus Time Chart** (Bar Chart)
- **Layout**: Biểu đồ cột dọc theo từng ngày
- **Trục X**: Thứ trong tuần (Mo, Tu, We, Th, Fr, Sa, Su)
- **Trục Y**: Giờ (0-7)
- **Màu sắc**: Mỗi cột có nhiều màu chồng lên nhau (stacked bar)
  - Màu sắc đa dạng: đỏ, cam, vàng, xanh lá, xanh dương, tím, hồng
- **Filter**: Dropdown "Biweekly"

## 🏗️ Cấu Trúc Thay Đổi

### Files Cần Chỉnh Sửa

1. **[`lib/features/report/presentation/widgets/summary_card.dart`](lib/features/report/presentation/widgets/summary_card.dart)**
   - Thêm màu nền coral/đỏ nhạt
   - Thay đổi màu text giá trị sang đỏ đậm
   - Điều chỉnh padding và kích thước font

2. **[`lib/features/report/presentation/widgets/pomodoro_records_chart.dart`](lib/features/report/presentation/widgets/pomodoro_records_chart.dart)**
   - Hiện tại: Timeline horizontal với các thanh màu theo project
   - Mới: Lưới dạng bảng với các ô nhỏ nhiều màu
   - Cần redesign hoàn toàn layout

3. **[`lib/features/report/presentation/widgets/focus_time_bar_chart.dart`](lib/features/report/presentation/widgets/focus_time_bar_chart.dart)**
   - Giữ nguyên cấu trúc fl_chart
   - Thêm nhiều màu sắc hơn cho các project
   - Điều chỉnh styling cho đẹp hơn

4. **[`lib/features/report/presentation/tab/pomodoro_report_tab.dart`](lib/features/report/presentation/tab/pomodoro_report_tab.dart:59)**
   - Cập nhật layout của summary cards
   - Thêm proper spacing để tránh overflow
   - Sử dụng `SingleChildScrollView` với `ConstrainedBox`

### Files Cần Tạo Mới

5. **`lib/features/report/data/mock_data_generator.dart`**
   - Service để tạo dữ liệu mẫu cho Pomodoro sessions
   - Tạo nhiều sessions với thời gian và màu sắc đa dạng
   - Tạo nhiều projects với màu sắc khác nhau

## 📊 Dữ Liệu Mẫu

### Projects Mẫu (với màu sắc)
```dart
final mockProjects = [
  Project(id: 'p1', name: 'Work Project', color: Color(0xFFFF6B6B)), // Đỏ
  Project(id: 'p2', name: 'Study', color: Color(0xFFFFD93D)), // Vàng
  Project(id: 'p3', name: 'Exercise', color: Color(0xFF6BCF7F)), // Xanh lá
  Project(id: 'p4', name: 'Reading', color: Color(0xFF4ECDC4)), // Xanh dương
  Project(id: 'p5', name: 'Coding', color: Color(0xFF95E1D3)), // Xanh mint
  Project(id: 'p6', name: 'Writing', color: Color(0xFFFFA07A)), // Cam nhạt
  Project(id: 'p7', name: 'Music', color: Color(0xFFB388EB)), // Tím
  Project(id: 'p8', name: 'Art', color: Color(0xFFFF85C1)), // Hồng
];
```

### Pomodoro Sessions Mẫu
- Tạo sessions cho 14 ngày gần đây
- Mỗi ngày có 4-8 sessions
- Thời gian: 8:00 - 20:00
- Duration: 25 phút hoặc 50 phút (1-2 Pomodoro)
- Random project cho mỗi session

### Focus Time Data
- Today: 2h 5m
- This Week: 39h 35m
- This Two Weeks: 79h 10m
- This Month: 160h 25m

## 🎯 Các Thay Đổi Chi Tiết

### 1. SummaryCard Widget

**Thay đổi:**
- Background: `Color(0xFFFFE5E5)` (coral nhạt)
- Value color: `Color(0xFFFF6B6B)` (đỏ đậm)
- Font size value: 24-28 (lớn hơn)
- Label color: `Colors.grey.shade600`

**Code mẫu:**
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFFFFE5E5),
    borderRadius: BorderRadius.circular(12),
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text(value, style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF6B6B),
      )),
      Text(label, style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      )),
    ],
  ),
)
```

### 2. PomodoroRecordsChart Widget

**Redesign hoàn toàn:**

**Cấu trúc mới:**
```
┌──────────┬────┬────┬────┬────┬────┬────┬────┐
│  Label   │18:00│9:00│4:00│6:00│8:00│10:00│20:00│
├──────────┼────┼────┼────┼────┼────┼────┼────┤
│  Today   │ ▪▪ │ ▪▪ │ ▪▪ │ ▪▪ │ ▪▪ │ ▪  │ ▪  │
│ Dec 19   │ ▪▪ │ ▪  │ ▪▪ │ ▪  │ ▪▪ │ ▪▪ │ ▪  │
│ Dec 18   │ ▪  │ ▪▪ │ ▪  │ ▪▪ │ ▪  │ ▪▪ │ ▪▪ │
│   ...    │    │    │    │    │    │    │    │
└──────────┴────┴────┴────┴────┴────┴────┴────┘
```

Mỗi ô (▪) là một Container nhỏ với màu của project tương ứng.

**Layout:**
- GridView hoặc Column of Rows
- Mỗi hàng có 8 cột (1 label + 7 time slots)
- Mỗi ô time slot chứa nhiều Container nhỏ (sessions)

### 3. Focus Time Bar Chart

**Giữ nguyên cấu trúc fl_chart, chỉ cải thiện:**
- Thêm nhiều màu sắc cho projects
- Điều chỉnh bar width và spacing
- Cải thiện legend (nếu cần)

### 4. Layout Tránh Overflow

**Chiến lược:**
```dart
SingleChildScrollView(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height,
    ),
    child: IntrinsicHeight(
      child: Column(
        children: [
          // Summary Cards với Wrap
          Wrap(spacing: 16, runSpacing: 16, children: cards),
          
          // Pomodoro Records với Card
          Card(child: PomodoroRecordsChart(...)),
          
          // Focus Goal với Card
          Card(child: TableCalendar(...)),
          
          // Focus Chart với Card  
          Card(child: FocusTimeBarChart(...)),
        ],
      ),
    ),
  ),
)
```

## 🔧 Kế Hoạch Triển Khai

### Phase 1: Chuẩn Bị Dữ Liệu
1. ✅ Tạo `mock_data_generator.dart`
2. ✅ Tạo danh sách projects với màu sắc
3. ✅ Tạo Pomodoro sessions mẫu cho 14 ngày
4. ✅ Tích hợp vào ReportCubit hoặc ReportRepository

### Phase 2: Cập Nhật Widgets
5. ✅ Cập nhật [`SummaryCard`](lib/features/report/presentation/widgets/summary_card.dart)
6. ✅ Redesign [`PomodoroRecordsChart`](lib/features/report/presentation/widgets/pomodoro_records_chart.dart)
7. ✅ Cải thiện [`FocusTimeBarChart`](lib/features/report/presentation/widgets/focus_time_bar_chart.dart)

### Phase 3: Cập Nhật Layout
8. ✅ Cập nhật [`PomodoroReportTab`](lib/features/report/presentation/tab/pomodoro_report_tab.dart)
9. ✅ Test trên nhiều kích thước màn hình
10. ✅ Fix overflow issues

### Phase 4: Testing & Refinement
11. ✅ Test với dữ liệu mẫu
12. ✅ Điều chỉnh màu sắc và spacing
13. ✅ Verify thiết kế match với ảnh

## 🎨 Bảng Màu Sử Dụng

```dart
// Summary Cards
final summaryCardBackground = Color(0xFFFFE5E5); // Coral nhạt
final summaryCardValueColor = Color(0xFFFF6B6B); // Đỏ đậm

// Projects Colors
final projectColors = [
  Color(0xFFFF6B6B), // Đỏ
  Color(0xFFFFD93D), // Vàng
  Color(0xFF6BCF7F), // Xanh lá
  Color(0xFF4ECDC4), // Xanh dương
  Color(0xFF95E1D3), // Xanh mint
  Color(0xFFFFA07A), // Cam
  Color(0xFFB388EB), // Tím
  Color(0xFFFF85C1), // Hồng
  Color(0xFFFF9999), // Đỏ nhạt
  Color(0xFFFFCC99), // Cam nhạt
];

// Focus Goal Calendar
final goalMetDayBorder = Color(0xFFFF6B6B); // Đỏ cho vòng tròn
```

## 📱 Responsive Design

### Chiều Rộng Summary Cards
```dart
final screenWidth = MediaQuery.of(context).size.width;
final cardWidth = (screenWidth - 48) / 2; // 16 padding x2 + 16 spacing
```

### Chiều Cao Pomodoro Records Chart
- Tối đa 7-10 hàng (ngày)
- Mỗi hàng cao 40-50px
- Tổng chiều cao: 280-500px (scrollable nếu cần)

### Chart Height
- Focus Time Bar Chart: 200-250px
- Calendar: Auto (từ TableCalendar)

## ⚠️ Lưu Ý Quan Trọng

1. **Tránh Overflow:**
   - Luôn dùng `SingleChildScrollView`
   - Sử dụng `Flexible` hoặc `Expanded` khi cần
   - Test trên nhiều màn hình (nhỏ, trung bình, lớn)

2. **Performance:**
   - Limit số lượng sessions hiển thị (max 14 ngày)
   - Dùng `const` constructor khi có thể
   - Optimize build method

3. **Màu Sắc:**
   - Đảm bảo contrast tốt
   - Màu sắc nhất quán với thiết kế
   - Hỗ trợ dark mode (nếu cần)

## 🚀 Kết Quả Mong Đợi

Sau khi hoàn thành:
- ✅ Tab Pomodoro match 95% với thiết kế từ ảnh
- ✅ Dữ liệu mẫu hiển thị đầy đủ và đa dạng
- ✅ Không có overflow trên các màn hình khác nhau
- ✅ UI mượt mà, màu sắc hài hòa
- ✅ Code clean, dễ maintain

## 📚 Tài Liệu Tham Khảo

- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [table_calendar Documentation](https://pub.dev/packages/table_calendar)
- Flutter Layout Cheat Sheet
- Material Design Color System