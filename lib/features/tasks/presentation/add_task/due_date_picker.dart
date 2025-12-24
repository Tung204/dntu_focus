import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DueDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DueDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DueDatePicker> createState() => _DueDatePickerState();
}

class _DueDatePickerState extends State<DueDatePicker> {
  late DateTime _selectedDate;
  final DateTime _now = DateTime.now();
  String? _selectedQuickOption;

  // Màu coral chính theo design
  static const Color _coralColor = Color(0xFFFF7B6B);
  static const Color _coralLightColor = Color(0xFFFFF0ED);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? _now;
  }

  void _selectQuickOption(DateTime? date, String optionName) {
    setState(() {
      _selectedQuickOption = optionName;
      if (date != null) {
        _selectedDate = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Responsive sizing
    final double iconContainerSize = screenWidth < 360 ? 36.0 : 40.0;
    final double iconSize = screenWidth < 360 ? 16.0 : 18.0;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 6, bottom: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Due Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // Divider
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

            // Quick Options
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickOption(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Today',
                    color: const Color(0xFF4CAF50),
                    isSelected: _selectedQuickOption == 'Today',
                    onTap: () => _selectQuickOption(_now, 'Today'),
                    iconContainerSize: iconContainerSize,
                    iconSize: iconSize,
                  ),
                  _buildQuickOption(
                    icon: Icons.cloud_outlined,
                    label: 'Tomorrow',
                    color: const Color(0xFF2196F3),
                    isSelected: _selectedQuickOption == 'Tomorrow',
                    onTap:
                        () => _selectQuickOption(
                          _now.add(const Duration(days: 1)),
                          'Tomorrow',
                        ),
                    iconContainerSize: iconContainerSize,
                    iconSize: iconSize,
                  ),
                  _buildQuickOption(
                    icon: Icons.calendar_view_week_outlined,
                    label: 'This Week',
                    color: const Color(0xFF9C27B0),
                    isSelected: _selectedQuickOption == 'This Week',
                    onTap:
                        () => _selectQuickOption(
                          _now.add(
                            Duration(days: DateTime.daysPerWeek - _now.weekday),
                          ),
                          'This Week',
                        ),
                    iconContainerSize: iconContainerSize,
                    iconSize: iconSize,
                  ),
                  _buildQuickOption(
                    icon: Icons.event_outlined,
                    label: 'Planned',
                    color: _coralColor,
                    isSelected: _selectedQuickOption == 'Planned',
                    onTap: () => _selectQuickOption(null, 'Planned'),
                    iconContainerSize: iconContainerSize,
                    iconSize: iconSize,
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

            // Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TableCalendar(
                firstDay: DateTime(_now.year - 1, 1, 1),
                lastDay: _now.add(const Duration(days: 365 * 2)),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _selectedQuickOption = null;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 16,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 16,
                  ),
                  headerPadding: EdgeInsets.zero,
                  headerMargin: EdgeInsets.zero,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: _coralColor,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  todayDecoration: BoxDecoration(
                    color: _coralColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: isDark ? Colors.white : _coralColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  defaultTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                  weekendTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                  outsideDaysVisible: false,
                  outsideTextStyle: TextStyle(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                  disabledTextStyle: TextStyle(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  ),
                  cellMargin: EdgeInsets.zero,
                ),
                daysOfWeekHeight: 20,
                rowHeight: 32,
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.horizontalSwipe,
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  // OK Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedQuickOption == 'Planned') {
                            widget.onDateSelected(null);
                          } else {
                            widget.onDateSelected(_selectedDate);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('OK'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required double iconContainerSize,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border:
                  isSelected ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? color : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
