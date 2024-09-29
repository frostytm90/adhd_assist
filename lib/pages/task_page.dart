import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';  // Make sure your Task model is imported

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<Task> _tasks = [];  // List to store tasks

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,  // Number of tabs (All, Work, Personal, Wishlist)
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
          bottom: TabBar(
            isScrollable: false,  // Centralizes the tabs
            labelPadding: EdgeInsets.symmetric(horizontal: 24.0),  // Adds space between tabs
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
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  // Method to build the task list view for each category
Widget _buildTaskListView(TaskCategory category) {
  List<Task> filteredTasks = _filterTasks(category);

  if (filteredTasks.isEmpty) {
    return Center(child: Text('No tasks in this category'));
  }

  return ListView.builder(
    itemCount: filteredTasks.length,
    itemBuilder: (context, index) {
      final task = filteredTasks[index];
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),  // Adjust padding around the task
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,  // Aligns text and checkbox
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Space between text and checkbox
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
                children: [
                  Text(
                    task.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),  // Space between title and subtitle
                  Text(
                    'Priority: ${task.priority.toString().split('.').last}, '
                    'Due: ${task.dueDate != null ? DateFormat.yMMMd().format(task.dueDate!) : 'No due date'}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),  // Adds some space at the top to align the checkbox lower
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
      );
    },
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
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    TaskCategory _selectedCategory = TaskCategory.all;
    TaskPriority _selectedPriority = TaskPriority.medium;
    DateTime? _selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Task Description'),
              ),
              DropdownButton<TaskCategory>(
                value: _selectedCategory,
                onChanged: (TaskCategory? newCategory) {
                  setState(() {
                    _selectedCategory = newCategory!;
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
                value: _selectedPriority,
                onChanged: (TaskPriority? newPriority) {
                  setState(() {
                    _selectedPriority = newPriority!;
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
                  Text(_selectedDate == null
                      ? 'No due date set'
                      : 'Due Date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _pickDueDate(context).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
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
                  _titleController.text,
                  _descriptionController.text,
                  _selectedCategory,
                  _selectedPriority,
                  _selectedDate,
                );
                Navigator.of(context).pop();
              },
              child: Text('Add'),
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

  // Method to show the Edit Task dialog
  void _showEditTaskDialog(int index) {
    final _titleController = TextEditingController(text: _tasks[index].title);
    final _descriptionController = TextEditingController(text: _tasks[index].description);
    TaskCategory _selectedCategory = _tasks[index].category;
    TaskPriority _selectedPriority = _tasks[index].priority;
    DateTime? _selectedDate = _tasks[index].dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Task Description'),
              ),
              DropdownButton<TaskCategory>(
                value: _selectedCategory,
                onChanged: (TaskCategory? newCategory) {
                  setState(() {
                    _selectedCategory = newCategory!;
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
                value: _selectedPriority,
                onChanged: (TaskPriority? newPriority) {
                  setState(() {
                    _selectedPriority = newPriority!;
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
                  Text(_selectedDate == null
                      ? 'No due date set'
                      : 'Due Date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _pickDueDate(context).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
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
                _editTask(
                  index,
                  _titleController.text,
                  _descriptionController.text,
                  _selectedCategory,
                  _selectedPriority,
                  _selectedDate,
                );
                Navigator.of(context).pop();  // Close dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to edit an existing task
  void _editTask(int index, String title, String description, TaskCategory category, TaskPriority priority, DateTime? dueDate) {
    setState(() {
      _tasks[index].title = title;
      _tasks[index].description = description;
      _tasks[index].category = category;
      _tasks[index].priority = priority;
      _tasks[index].dueDate = dueDate;
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
