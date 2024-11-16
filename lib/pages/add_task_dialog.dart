import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

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
  bool _isRecurring = false;
  Recurrence? _selectedRecurrence;

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
        isRecurring: _isRecurring,
        recurrence: _isRecurring ? _selectedRecurrence : null,
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
                decoration: const InputDecoration(labelText: 'Task Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
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
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDueDate == null
                        ? 'No due date set'
                        : 'Due Date: ${DateFormat.yMMMd().format(_selectedDueDate!)}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDueDate,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Recurring Task'),
                value: _isRecurring,
                onChanged: (bool value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) {
                      _selectedRecurrence = null;
                    }
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<Recurrence>(
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  value: _selectedRecurrence,
                  items: Recurrence.values.map((Recurrence recurrence) {
                    return DropdownMenuItem<Recurrence>(
                      value: recurrence,
                      child: Text(recurrence.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRecurrence = newValue;
                    });
                  },
                  validator: (value) {
                    if (_isRecurring && value == null) {
                      return 'Please select a recurrence pattern';
                    }
                    return null;
                  },
                ),
              ],
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
