import 'package:flutter/material.dart';
import 'task_page.dart'; // Import TaskPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Updated the pages list to remove the Calendar page placeholder
  static final List<Widget> _pages = <Widget>[
    const TaskPage(key: ValueKey('taskPage')), // Task page for tasks
    const Center(child: Text('Profile Page Placeholder', key: ValueKey('profilePage'))), // Placeholder for Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list, key: ValueKey('tasksNavItem')),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, key: ValueKey('profileNavItem')),
            label: 'Mine',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
