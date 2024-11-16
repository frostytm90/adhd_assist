// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'task_page.dart'; // Import TaskPage
import 'profile_page.dart'; // Import ProfilePage
import 'add_task_dialog.dart'; // Import the Add Task Dialog widget
import '../models/task.dart'; // Import Task model to create new tasks

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Task> _tasks = []; // List to hold the tasks

  // Pages list, with TaskPage and ProfilePage
  List<Widget> get _pages => <Widget>[
        const TaskPage(), // Task page for tasks
        const ProfilePage(), // Add ProfilePage to the list
      ];
  // Updated the pages list to remove the Calendar page placeholder
  static final List<Widget> _pages = <Widget>[
    const TaskPage(key: ValueKey('taskPage')), // Task page for tasks
    const Center(
        child: Text('Profile Page Placeholder',
            key: ValueKey('profilePage'))), // Placeholder for Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task); // Add new task to the list
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
            icon: Icon(Icons.person),
            label: 'Profile', // Changed label to "Profile"
            icon: Icon(Icons.person, key: ValueKey('profileNavItem')),
            label: 'Mine',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              key: const ValueKey('addTaskButton'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddTaskDialog(
                    onTaskAdded: (newTask) {
                      _addTask(newTask); // Call _addTask to add the new task
                    },
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null, // Only show the FAB on the Task page
    );
  }
}
