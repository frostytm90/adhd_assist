import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';  // Import intl package for formatting

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();  // Initialize timezones
  await NotificationService().init();  // Initialize notification service
  runApp(TodoApp());
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  bool _isDarkMode = false; // Initially set to light mode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADHD Assist - To-Do List',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(), // Toggle between dark and light mode
      home: TodoListScreen(
        onThemeChange: _toggleTheme, // Pass theme change handler to the main screen
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
}

class TodoListScreen extends StatefulWidget {
  final Function onThemeChange;

  TodoListScreen({required this.onThemeChange});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];  // To store the filtered tasks for search
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Search controller

  String _selectedPriority = 'Medium';
  String _selectedCategory = 'General';  // Default category
  String _selectedRecurrence = 'None';  // Default recurrence
  DateTime? _selectedDueDate;  // Variable to store the due date
  TimeOfDay? _selectedDueTime;  // Variable to store the due time
  String _sortOption = 'Priority';  // Default sorting option
  String _filterOption = 'All';  // Default filter option

  final List<String> _categories = ['Work', 'Personal', 'Urgent', 'General']; // Task categories
  final List<String> _recurrenceOptions = ['None', 'Daily', 'Weekly', 'Monthly']; // Recurrence options

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _scheduleTestNotification(); // Schedule a test notification on app startup
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      List<Map<String, dynamic>> savedTasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      setState(() {
        _tasks.addAll(savedTasks);
        _filteredTasks = _tasks;  // Initialize filtered tasks as all tasks
      });
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  // Step 4: Adding validation for due date and time in the past
  void _addTask(String task, DateTime? reminderTime) {
    DateTime? finalDueDate;

    // Validate if due date and time are in the past
    if (_selectedDueDate != null && _selectedDueTime != null) {
      finalDueDate = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedDueTime!.hour,
        _selectedDueTime!.minute,
      );

      DateTime now = DateTime.now();
      if (finalDueDate.isBefore(now)) {
        _showErrorMessage(context, "Due date/time cannot be in the past.");
        return;
      }
    }

    setState(() {
      _tasks.add({
        'task': task,
        'completed': false,
        'priority': _selectedPriority,
        'category': _selectedCategory,
        'recurrence': _selectedRecurrence,
        'dueDate': finalDueDate?.toString(),  // Store final due date with time
        'reminderTime': reminderTime?.toString(),
        'key': UniqueKey().toString(),  // Unique key for reordering
      });
      _filteredTasks = _tasks;  // Update filtered tasks after adding a new one
    });

    if (reminderTime != null) {
      _scheduleNotification(task, reminderTime, _selectedPriority);  // Pass priority to the notification method
    }
    _textController.clear();
    _saveTasks();
    _sortTasks();  // Sort tasks after adding a new one
  }

  // Function to show error message if the due date/time is invalid
  void _showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _scheduleNotification(String task, DateTime reminderTime, String priority) async {
    await NotificationService().showTaskNotification(_tasks.length, task, reminderTime, priority);
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _filteredTasks[index]['completed'] = !_filteredTasks[index]['completed'];
    });
    _saveTasks();
  }

  void _removeTask(int index) {
    setState(() {
      _filteredTasks.removeAt(index);
    });
    _saveTasks();
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = _filteredTasks.removeAt(oldIndex);
      _filteredTasks.insert(newIndex, task);
    });
    _saveTasks();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;  // Store the selected due date
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDueTime = pickedTime;  // Store the selected due time
      });
    }
  }

  String _formatDueDate(String? dueDate) {
    if (dueDate == null) return 'No due date';
    DateTime parsedDate = DateTime.parse(dueDate);
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);  // Format date with 24-hour time
  }

  void _scheduleTestNotification() async {
    // Schedule a test notification 10 seconds after app launch to verify notifications
    DateTime now = DateTime.now();
    DateTime testReminderTime = now.add(const Duration(seconds: 10));  // Schedule a notification 10 seconds from now
    await NotificationService().showTaskNotification(999, "Test Notification", testReminderTime, "Medium");
  }

  // Step 1: Function to open the edit dialog and update task details
  void _editTask(int index) {
    final task = _filteredTasks[index];
    _textController.text = task['task'];  // Pre-fill the task name

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Edit task',
                ),
              ),
              DropdownButton<String>(
                value: task['priority'],
                items: ['Low', 'Medium', 'High'].map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? newPriority) {
                  setState(() {
                    task['priority'] = newPriority ?? 'Medium';
                  });
                },
              ),
              DropdownButton<String>(
                value: task['category'],
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newCategory) {
                  setState(() {
                    task['category'] = newCategory ?? 'General';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  task['task'] = _textController.text;
                  _saveTasks();  // Save the updated task
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Step 2: Sorting the tasks
  void _sortTasks() {
    setState(() {
      if (_sortOption == 'Priority') {
        _filteredTasks.sort((a, b) {
          return _comparePriority(a['priority'], b['priority']);
        });
      } else if (_sortOption == 'Due Date') {
        _filteredTasks.sort((a, b) {
          return _compareDueDate(a['dueDate'], b['dueDate']);
        });
      } else if (_sortOption == 'Category') {
        _filteredTasks.sort((a, b) {
          return a['category'].compareTo(b['category']);
        });
      }
    });
  }

  int _comparePriority(String a, String b) {
    const priorities = {'High': 3, 'Medium': 2, 'Low': 1};
    return priorities[b]! - priorities[a]!;  // Sort in descending order (High -> Low)
  }

  int _compareDueDate(String? a, String? b) {
    if (a == null) return 1;
    if (b == null) return -1;
    return DateTime.parse(a).compareTo(DateTime.parse(b));
  }

  // Step 3: Search tasks by name
  void _searchTasks(String query) {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        return task['task'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Step 6: Method to filter tasks based on the selected filter option
  void _filterTasks(String filterOption) {
    setState(() {
      if (filterOption == 'Completed') {
        _filteredTasks = _tasks.where((task) => task['completed'] == true).toList();
      } else if (filterOption == 'Incomplete') {
        _filteredTasks = _tasks.where((task) => task['completed'] == false).toList();
      } else {
        _filteredTasks = _tasks;  // Show all tasks
      }
    });
  }

  // Step 5: Method to calculate task completion statistics
  int _getCompletedTasksCount() {
    return _tasks.where((task) => task['completed'] == true).length;
  }

  int _getTotalTasksCount() {
    return _tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADHD Assist - To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // No need for const here
            onPressed: () async {
              await NotificationService().showImmediateNotification();
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6), // Icon for toggling light/dark mode
            onPressed: () {
              widget.onThemeChange();  // Toggle dark/light mode
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Step 6: Add Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButton<String>(
              value: _filterOption,
              items: ['All', 'Completed', 'Incomplete'].map((String filterOption) {
                return DropdownMenuItem<String>(
                  value: filterOption,
                  child: Text('Filter: $filterOption'),
                );
              }).toList(),
              onChanged: (String? newFilterOption) {
                setState(() {
                  _filterOption = newFilterOption ?? 'All';
                  _filterTasks(_filterOption);  // Filter tasks based on the selected filter
                });
              },
            ),
          ),

          // Step 2: Add Sorting Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButton<String>(
              value: _sortOption,
              items: ['Priority', 'Due Date', 'Category'].map((String sortOption) {
                return DropdownMenuItem<String>(
                  value: sortOption,
                  child: Text('Sort by $sortOption'),
                );
              }).toList(),
              onChanged: (String? newSortOption) {
                setState(() {
                  _sortOption = newSortOption ?? 'Priority';
                  _sortTasks();  // Sort tasks based on selected option
                });
              },
            ),
          ),

          // Step 3: Add Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search tasks...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchTasks(value);  // Update the task list based on the search query
              },
            ),
          ),

          // Step 5: Task Completion Statistics
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Completed ${_getCompletedTasksCount()} of ${_getTotalTasksCount()} tasks',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Enter task',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedPriority,
                        items: ['Low', 'Medium', 'High'].map((String priority) {
                          return DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (String? newPriority) {
                          setState(() {
                            _selectedPriority = newPriority ?? 'Medium';
                          });
                        },
                        hint: const Text('Select Priority'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newCategory) {
                          setState(() {
                            _selectedCategory = newCategory ?? 'General';
                          });
                        },
                        hint: const Text('Select Category'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRecurrence,
                        items: _recurrenceOptions.map((String recurrence) {
                          return DropdownMenuItem<String>(
                            value: recurrence,
                            child: Text(recurrence),
                          );
                        }).toList(),
                        onChanged: (String? newRecurrence) {
                          setState(() {
                            _selectedRecurrence = newRecurrence ?? 'None';
                          });
                        },
                        hint: const Text('Select Recurrence'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () {
                        _selectDueDate(context);  // Open date picker for selecting the due date
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () {
                        _selectDueTime(context);  // Open time picker for selecting the due time
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        if (_textController.text.isNotEmpty) {
                          _addTask(_textController.text, null);
                          _sortTasks();  // Sort tasks after adding a new one
                        }
                      },
                    ),
                  ],
                ),
                if (_selectedDueDate != null && _selectedDueTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Due: ${_selectedDueDate!.toLocal()} at ${_selectedDueTime!.format(context)}'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _filteredTasks.length,  // Use filtered tasks for the list
              onReorder: _reorderTasks,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return ListTile(
                  key: Key(task['key']),
                  leading: Checkbox(
                    value: task['completed'],
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(index);
                    },
                  ),
                  title: Text(
                    task['task'],
                    style: TextStyle(
                      decoration: task['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text('Priority: ${task['priority']} | Category: ${task['category']} | Due: ${_formatDueDate(task['dueDate'])}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editTask(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTask(index),
                      ),
                    ],
                  ),
                  tileColor: _getPriorityColor(task['priority']).withOpacity(0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    // Request notification permissions
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      // Handle the case where the app was launched by a notification
    }
  }

  // Function to show an immediate notification
  Future<void> showImmediateNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      999,  // Unique notification ID
      'Immediate Notification',
      'This is a test notification',
      notificationDetails,
    );
  }

  // Function to show task notification with action buttons
  Future<void> showTaskNotification(int id, String task, DateTime reminderTime, String priority) async {
    // Adjusting the priority of the notification based on the task's priority level
    Importance importance = (priority == 'High') ? Importance.max : Importance.defaultImportance;
    Priority notificationPriority = (priority == 'High') ? Priority.high : Priority.defaultPriority;

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: importance,
      priority: notificationPriority,
      playSound: true,
      enableVibration: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Task Reminder',
      task,
      tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Handling notification button actions
  void onSelectNotification(NotificationResponse notificationResponse) {
    // Handle notification action here
  }
}
