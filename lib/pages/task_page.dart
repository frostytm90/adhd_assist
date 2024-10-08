// pages/task_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding and decoding

import '../models/task.dart';
import 'task_details_page.dart';
import 'task_calendar_page.dart';
import 'task_reorder_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the app starts
  }

  // Method to load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskStrings = prefs.getStringList('tasks');
    if (taskStrings != null) {
      setState(() {
        _tasks.addAll(taskStrings.map((taskString) => Task.fromJson(jsonDecode(taskString))));
      });
    }
  }

  // Method to save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskCalendarPage(tasks: _tasks),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.reorder),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskReorderPage(tasks: _tasks),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            labelPadding: EdgeInsets.symmetric(horizontal: 24.0),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Work'),
              Tab(text: 'Personal'),
              Tab(text: 'Wishlist'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskListView(TaskCategory.all),
            _buildTaskListView(TaskCategory.work),
            _buildTaskListView(TaskCategory.personal),
            _buildTaskListView(TaskCategory.wishlist),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskListView(TaskCategory category) {
    List<Task> filteredTasks = _filterTasks(category);

    if (filteredTasks.isEmpty) {
      return const Center(child: Text('No tasks in this category'));
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return GestureDetector(
          onTap: () => _navigateToTaskDetailsPage(task),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      task.isCompleted = value ?? false;
                      _saveTasks(); // Save changes after marking task completed
                    });
                  },
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Priority: ${task.priority.toString().split('.').last}, '
                        'Due: ${task.dueDate != null ? DateFormat.yMMMd().format(task.dueDate!) : 'No due date'}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToTaskDetailsPage(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: task,
          onDelete: () {
            setState(() {
              _tasks.remove(task);
              _saveTasks(); // Save tasks after deleting
            });
            Navigator.of(context).pop();
          },
          onEdit: () {
            setState(() {
              _saveTasks(); // Save tasks after editing
            });
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }

  List<Task> _filterTasks(TaskCategory category) {
    if (category == TaskCategory.all) {
      return _tasks;
    } else {
      return _tasks.where((task) => task.category == category).toList();
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.all;
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Task Description'),
              ),
              DropdownButton<TaskCategory>(
                value: selectedCategory,
                onChanged: (TaskCategory? newCategory) {
                  setState(() {
                    selectedCategory = newCategory!;
                  });
                },
                items: TaskCategory.values.map<DropdownMenuItem<TaskCategory>>((TaskCategory category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
              ),
              DropdownButton<TaskPriority>(
                value: selectedPriority,
                onChanged: (TaskPriority? newPriority) {
                  setState(() {
                    selectedPriority = newPriority!;
                  });
                },
                items: TaskPriority.values.map<DropdownMenuItem<TaskPriority>>((TaskPriority priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
              ),
              Row(
                children: <Widget>[
                  Text(selectedDate == null
                      ? 'No due date set'
                      : 'Due Date: ${DateFormat.yMMMd().format(selectedDate!)}'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _pickDueDate(context).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _addTask(
                  titleController.text,
                  descriptionController.text,
                  selectedCategory,
                  selectedPriority,
                  selectedDate,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(String title, String description, TaskCategory category, TaskPriority priority, DateTime? dueDate) {
    setState(() {
      _tasks.add(Task(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      ));
      _saveTasks(); // Save tasks after adding a new one
    });
  }

  Future<DateTime?> _pickDueDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}
