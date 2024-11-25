import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCalendarPage extends StatefulWidget {
  final List<Task> tasks; // Pass all tasks here

  const TaskCalendarPage({super.key, required this.tasks});

  @override
  _TaskCalendarPageState createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Filter tasks by the selected date
  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      if (task.dueDate != null) {
        return isSameDay(task.dueDate, day); // Filter tasks for the selected day
      }
      return false;
    }).toList();
  }

  // Get color based on task category
  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.all:
        return Colors.grey;
      case TaskCategory.daily:
        return Colors.green;  // Green for daily tasks
      case TaskCategory.important:
        return Colors.red;    // Red for important tasks
      case TaskCategory.goals:
        return Colors.blue;   // Blue for long-term goals
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            key: const ValueKey('taskCalendar'),
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Update the focused day
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => _getTasksForDay(day),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, tasks) {
                if (tasks.isNotEmpty) {
                  Task task = tasks.first as Task; // Cast tasks.first to Task
                  TaskCategory category = task.category;

                  return Container(
                    key: ValueKey('marker_${date.toIso8601String()}'),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      shape: BoxShape.circle,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: _buildTaskListView(_getTasksForDay(_selectedDay)), // Display tasks for the selected day
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListView(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks for this day.'));
    }
    return ListView.builder(
      key: const ValueKey('taskListView'),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          key: ValueKey('task_${task.id}'),
          title: Text(task.title),
          subtitle: Text(
            'Due: ${task.dueDate != null ? DateFormat.yMMMd().format(task.dueDate!) : 'No due date'}',
          ),
          trailing: Checkbox(
            key: ValueKey('checkbox_${task.id}'),
            value: task.isCompleted,
            onChanged: (bool? value) {
              setState(() {
                task.isCompleted = value ?? false;
              });
            },
          ),
          onTap: () {
            // Navigate to task details or editing
          },
        );
      },
    );
  }
}
