import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskDetailsPage({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late String _title;
  late String _description;
  late TaskCategory _category;
  late TaskPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;
    _category = widget.task.category;
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            key: const ValueKey('editTaskButton'),
            icon: const Icon(Icons.edit),
            onPressed: _showEditTaskDialog, // Edit task button
          ),
          IconButton(
            key: const ValueKey('deleteTaskButton'),
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              key: const ValueKey('taskTitle'),
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Description: $_description',
              key: const ValueKey('taskDescription'),
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Category: ${_category.toString().split('.').last}',
              key: const ValueKey('taskCategory'),
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Priority: ${_priority.toString().split('.').last}',
              key: const ValueKey('taskPriority'),
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Due Date: ${_dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'No due date'}',
              key: const ValueKey('taskDueDate'),
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog() {
    final titleController = TextEditingController(text: _title);
    final descriptionController = TextEditingController(text: _description);
    TaskCategory selectedCategory = _category;
    TaskPriority selectedPriority = _priority;
    DateTime? selectedDate = _dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                key: const ValueKey('editTaskTitleField'),
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                key: const ValueKey('editTaskDescriptionField'),
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Task Description'),
              ),
              DropdownButton<TaskCategory>(
                key: const ValueKey('editTaskCategoryDropdown'),
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
                key: const ValueKey('editTaskPriorityDropdown'),
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
                  Text(
                    selectedDate == null
                        ? 'No due date set'
                        : 'Due Date: ${DateFormat.yMMMd().format(selectedDate!)}',
                    key: const ValueKey('editTaskDueDateText'),
                  ),
                  IconButton(
                    key: const ValueKey('editTaskDueDateButton'),
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
              key: const ValueKey('saveTaskButton'),
              onPressed: () {
                setState(() {
                  _title = titleController.text;
                  _description = descriptionController.text;
                  _category = selectedCategory;
                  _priority = selectedPriority;
                  _dueDate = selectedDate;
                });
                widget.onEdit();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
