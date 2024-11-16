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
  TaskCategory _selectedCategory = TaskCategory.personal;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;
  bool _isRecurring = false;
  Recurrence? _selectedRecurrence;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.medium;
  bool _showAdvancedOptions = false;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDate,
        recurrence: _isRecurring ? _selectedRecurrence : null,
        difficulty: _selectedDifficulty,
      );

      widget.onTaskAdded(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'What do you need to do?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _PriorityButton(
                          label: '!',
                          isSelected: _selectedPriority == TaskPriority.low,
                          onTap: () => setState(() => _selectedPriority = TaskPriority.low),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityButton(
                          label: '!!',
                          isSelected: _selectedPriority == TaskPriority.medium,
                          onTap: () => setState(() => _selectedPriority = TaskPriority.medium),
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityButton(
                          label: '!!!',
                          isSelected: _selectedPriority == TaskPriority.high,
                          onTap: () => setState(() => _selectedPriority = TaskPriority.high),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    children: [
                      _DateChip(
                        label: 'Today',
                        isSelected: _selectedDate?.day == DateTime.now().day,
                        onTap: () => setState(() => _selectedDate = DateTime.now()),
                      ),
                      _DateChip(
                        label: 'Tomorrow',
                        isSelected: _selectedDate?.day == DateTime.now().add(const Duration(days: 1)).day,
                        onTap: () => setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1))),
                      ),
                      _DateChip(
                        label: 'Pick Date',
                        isSelected: _selectedDate != null && 
                                  _selectedDate!.day != DateTime.now().day && 
                                  _selectedDate!.day != DateTime.now().add(const Duration(days: 1)).day,
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
                    icon: Icon(_showAdvancedOptions ? Icons.expand_less : Icons.expand_more),
                    label: Text(_showAdvancedOptions ? 'Less Options' : 'More Options'),
                  ),

                  if (_showAdvancedOptions) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Add details (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Repeat this task?'),
                            value: _isRecurring,
                            onChanged: (value) {
                              setState(() {
                                _isRecurring = value;
                                if (!value) _selectedRecurrence = null;
                              });
                            },
                          ),
                          if (_isRecurring)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildRecurrenceDropdown(),
                            ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<TaskCategory>(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.category),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedCategory,
      items: TaskCategory.values.map((TaskCategory category) {
        return DropdownMenuItem<TaskCategory>(
          value: category,
          child: Text(
            category.toString().split('.').last,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
    );
  }

  Widget _buildRecurrenceDropdown() {
    return DropdownButtonFormField<Recurrence>(
      decoration: InputDecoration(
        labelText: 'Recurrence',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.update),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedRecurrence,
      items: Recurrence.values.map((Recurrence recurrence) {
        return DropdownMenuItem<Recurrence>(
          value: recurrence,
          child: Text(
            recurrence.toString().split('.').last,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedRecurrence = newValue;
        });
      },
      validator: (value) {
        if (_isRecurring && value == null) {
          return 'Please select recurrence';
        }
        return null;
      },
    );
  }
}

class _PriorityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _PriorityButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
      ),
      backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
      onPressed: onTap,
    );
  }
}
