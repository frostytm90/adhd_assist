// pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('remindersEnabled') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('remindersEnabled', _remindersEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: Consumer2<TaskProvider, ThemeProvider>(
        builder: (context, taskProvider, themeProvider, child) {
          final tasks = taskProvider.tasks;
          final completedTasks = tasks.where((task) => task.isCompleted).length;
          final remainingTasks = tasks.length - completedTasks;
          
          // Calculate tasks by category
          final Map<TaskCategory, int> tasksByCategory = {};
          for (var category in TaskCategory.values) {
            tasksByCategory[category] = tasks
                .where((task) => task.category == category && !task.isCompleted)
                .length;
          }

          // Calculate overdue tasks
          final overdueTasks = tasks
              .where((task) =>
                  !task.isCompleted &&
                  task.dueDate != null &&
                  task.dueDate!.isBefore(DateTime.now()))
              .length;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Summary',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _buildSummaryItem(
                        'Completed Tasks',
                        completedTasks,
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildSummaryItem(
                        'Remaining Tasks',
                        remainingTasks,
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _buildSummaryItem(
                        'Overdue Tasks',
                        overdueTasks,
                        Icons.warning,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tasks by Category',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ...TaskCategory.values
                          .where((category) => category != TaskCategory.all)
                          .map((category) => _buildSummaryItem(
                                category.toString().split('.').last,
                                tasksByCategory[category] ?? 0,
                                Icons.folder,
                                Colors.blue,
                              )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Theme'),
                      subtitle: const Text('Enable dark mode'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) async {
                        await themeProvider.toggleTheme();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Reminders'),
                      subtitle: const Text('Enable task reminders'),
                      value: _remindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _remindersEnabled = value;
                          _savePreferences();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
