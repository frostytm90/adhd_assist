import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/task.dart'; // Correct path to the Task model
import 'task_details_page.dart'; // Correct path to TaskDetailsPage
import 'task_calendar_page.dart'; // Import the task calendar page
import 'task_reorder_page.dart'; // Import the task reorder page

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<Task> _tasks = []; // List to store tasks

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs (All, Work, Personal, Wishlist)
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          actions: [
            // Button to navigate to Task Calendar
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskCalendarPage(tasks: _tasks), // Navigate to the TaskCalendarPage
                  ),
                );
              },
            ),
            // Button to navigate to Task Reordering
            IconButton(
              icon: const Icon(Icons.reorder),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskReorderPage(tasks: _tasks), // Navigate to the TaskReorderPage
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: false, // Centralizes the tabs
            labelPadding: EdgeInsets.symmetric(horizontal: 24.0), // Adds space between tabs
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

  // Method to build the task list view for each category
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
          onTap: () => _navigateToTaskDetailsPage(task), // Navigate to task details on tap
          child: Container( // Use Container to wrap the entire row and make it tappable
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding around the entire task row
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns text and checkbox
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between text and checkbox
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0), // Space between title and subtitle
                      Text(
                        'Priority: ${task.priority.toString().split('.').last}, '
                        'Due: ${task.dueDate != null ? DateFormat.yMMMd().format(task.dueDate!) : 'No due date'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0), // Adds some space at the top to align the checkbox lower
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        task.isCompleted = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add the navigation function to navigate to task details
  void _navigateToTaskDetailsPage(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: task,
          onDelete: () {
            setState(() {
              _tasks.remove(task); // Handle task deletion
            });
            Navigator.of(context).pop(); // Close details page after deletion
          },
          onEdit: () {
            // Handle task editing
          },
        ),
      ),
    );
  }

  // Method to filter tasks based on their category
  List<Task> _filterTasks(TaskCategory category) {
    if (category == TaskCategory.all) {
      return _tasks;
    } else {
      return _tasks.where((task) => task.category == category).toList();
    }
  }

  // Method to show the Add Task dialog
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

  // Method to add a new task
  void _addTask(String title, String description, TaskCategory category, TaskPriority priority, DateTime? dueDate) {
    setState(() {
      _tasks.add(Task(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      ));
    });
  }

  // Method to pick a due date
  Future<DateTime?> _pickDueDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}
