import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'screens/this_week_screen.dart';
import 'screens/community_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/friends_screen.dart';

class MainShell extends StatefulWidget {
  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CalendarScreen(),
    ThisWeekScreen(),
    CommunityScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'This Week'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white60,
        backgroundColor: Color(0xff232222),
        type: BottomNavigationBarType.fixed,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
