import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine fontSize based on screen size or a fixed smaller value
    // double labelFontSize = MediaQuery.of(context).size.width < 360 ? 10.0 : 12.0; // Example
    double labelFontSize = 11.0; // Or try a fixed smaller value

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w600), // FontWeight for selected item
      unselectedLabelStyle: TextStyle(fontSize: labelFontSize),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.timer_outlined),
          label: 'Pomodoro',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.widgets_outlined),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Report',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          label: 'Chat',
        ),
      ],
    );
  }
}