import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'task_details_page.dart';

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
          key: const ValueKey('addTaskButton'),
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
          key: ValueKey('taskItem_${task.title}_$index'),
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
                  key: ValueKey('taskCheckbox_${task.title}_$index'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      task.isCompleted = value ?? false;
                      if (task.isRecurring && task.isCompleted) {
                        _addRecurringTask(task);
                      }
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
                        key: ValueKey('taskTitle_${task.title}_$index'),
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

  // Method to filter tasks based on their category
  List<Task> _filterTasks(TaskCategory category) {
    if (category == TaskCategory.all) {
      return _tasks;
    } else {
      return _tasks.where((task) => task.category == category).toList();
    }
  }

  // Method to navigate to the task details page
  void _navigateToTaskDetailsPage(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: task,
          onDelete: () {
            setState(() {
              _tasks.remove(task);
            });
            Navigator.of(context).pop();
          },
          onEdit: () {
            setState(() {
              // Refresh the state after editing
            });
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }

  // Method to show the Add Task dialog
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.all;
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDate;
    bool isRecurring = false;
    Recurrence? selectedRecurrence;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      key: const ValueKey('addTaskTitleField'),
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Task Title'),
                    ),
                    TextField(
                      key: const ValueKey('addTaskDescriptionField'),
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Task Description'),
                    ),
                    DropdownButton<TaskCategory>(
                      key: const ValueKey('addTaskCategoryDropdown'),
                      value: selectedCategory,
                      onChanged: (TaskCategory? newCategory) {
                        setDialogState(() {
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
                      key: const ValueKey('addTaskPriorityDropdown'),
                      value: selectedPriority,
                      onChanged: (TaskPriority? newPriority) {
                        setDialogState(() {
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
                        Text(
                          selectedDate == null
                              ? 'No due date set'
                              : 'Due Date: ${DateFormat.yMMMd().format(selectedDate!)}',
                          key: const ValueKey('addTaskDueDateText'),
                        ),
                        IconButton(
                          key: const ValueKey('addTaskDueDateButton'),
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            _pickDueDate(context).then((pickedDate) {
                              if (pickedDate != null) {
                                setDialogState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SwitchListTile(
                      key: const ValueKey('addTaskRecurringSwitch'),
                      title: const Text('Recurring Task'),
                      value: isRecurring,
                      onChanged: (bool value) {
                        setDialogState(() {
                          isRecurring = value;
                          if (!value) {
                            selectedRecurrence = null;
                          }
                        });
                      },
                    ),
                    if (isRecurring)
                      DropdownButton<Recurrence>(
                        key: const ValueKey('addTaskRecurrenceDropdown'),
                        value: selectedRecurrence,
                        onChanged: (Recurrence? newRecurrence) {
                          setDialogState(() {
                            selectedRecurrence = newRecurrence;
                          });
                        },
                        items: Recurrence.values.map<DropdownMenuItem<Recurrence>>((Recurrence recurrence) {
                          return DropdownMenuItem<Recurrence>(
                            value: recurrence,
                            child: Text(recurrence.toString().split('.').last),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  key: const ValueKey('addTaskSaveButton'),
                  onPressed: () {
                    _addTask(
                      titleController.text,
                      descriptionController.text,
                      selectedCategory,
                      selectedPriority,
                      selectedDate,
                      isRecurring,
                      selectedRecurrence,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to add a new task
  void _addTask(String title, String description, TaskCategory category, TaskPriority priority, DateTime? dueDate,
      bool isRecurring, Recurrence? recurrence) {
    setState(() {
      _tasks.add(Task(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
        isRecurring: isRecurring,
        recurrence: recurrence,
      ));
    });
  }

  // Method to add a recurring task
  void _addRecurringTask(Task completedTask) {
    DateTime nextDueDate;
    switch (completedTask.recurrence) {
      case Recurrence.daily:
        nextDueDate = completedTask.dueDate!.add(const Duration(days: 1));
        break;
      case Recurrence.weekly:
        nextDueDate = completedTask.dueDate!.add(const Duration(days: 7));
        break;
      case Recurrence.monthly:
        nextDueDate = DateTime(
          completedTask.dueDate!.year,
          completedTask.dueDate!.month + 1,
          completedTask.dueDate!.day,
        );
        break;
      default:
        return;
    }

    _addTask(
      completedTask.title,
      completedTask.description,
      completedTask.category,
      completedTask.priority,
      nextDueDate,
      completedTask.isRecurring,
      completedTask.recurrence,
    );
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
