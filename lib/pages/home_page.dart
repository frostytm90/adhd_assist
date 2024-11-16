// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_page.dart';
import 'profile_page.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages list
  final List<Widget> _pages = [
    const TaskPage(),
    const ProfilePage(),
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
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddTaskDialog(
                    onTaskAdded: (Task newTask) {
                      context.read<TaskProvider>().addTask(newTask);
                    },
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
