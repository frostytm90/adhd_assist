import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart'; // Adjust this import based on your project structure

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TaskCategory? _selectedCategory;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;

  void _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      Task newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? TaskCategory.personal,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );

      widget.onTaskAdded(newTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Task Description'),
              ),
              DropdownButtonFormField<TaskCategory>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: TaskCategory.values.map((TaskCategory category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              DropdownButtonFormField<TaskPriority>(
                decoration: const InputDecoration(labelText: 'Priority'),
                value: _selectedPriority,
                items: TaskPriority.values.map((TaskPriority priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Text(_selectedDueDate == null
                      ? 'No due date set'
                      : 'Due Date: ${DateFormat.yMMMd().format(_selectedDueDate!)}'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDueDate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
