import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart'; // Correct path to the Task model

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final Function onDelete;
  final Function onEdit;

  TaskDetailsPage({required this.task, required this.onDelete, required this.onEdit});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late TaskPriority _selectedPriority;
  late DateTime? _selectedDate;
  bool _isRecurring = false;
  Recurrence? _selectedRecurrence;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _selectedPriority = widget.task.priority;
    _selectedDate = widget.task.dueDate;
    _isRecurring = widget.task.isRecurring;
    _selectedRecurrence = widget.task.recurrence;
  }

  void _updateTask() {
  setState(() {
    widget.task.title = _titleController.text;
    widget.task.description = _descriptionController.text;
    widget.task.priority = _selectedPriority;
    widget.task.dueDate = _selectedDate;
    widget.task.notes = _notesController.text;
    widget.task.isRecurring = _isRecurring;
    widget.task.recurrence = _selectedRecurrence;
  });

  widget.onEdit(); // Notify parent of changes
  // Removed Navigator.pop() here to avoid extra screen pop
}

  void _addSubtask() {
    setState(() {
      widget.task.subtasks.add(Subtask(title: 'New Subtask'));
    });
  }

  void _toggleSubtaskCompletion(int index) {
    setState(() {
      widget.task.subtasks[index].isCompleted = !widget.task.subtasks[index].isCompleted;
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      widget.task.subtasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _updateTask,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Task Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16.0),
            // Task Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            // Task Priority
            DropdownButton<TaskPriority>(
              value: _selectedPriority,
              onChanged: (TaskPriority? newPriority) {
                setState(() {
                  _selectedPriority = newPriority!;
                });
              },
              items: TaskPriority.values.map((TaskPriority priority) {
                return DropdownMenuItem<TaskPriority>(
                  value: priority,
                  child: Text(priority.toString().split('.').last),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            // Due Date
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
            SizedBox(height: 16.0),
            // Subtasks Section
            Text('Subtasks:'),
            SizedBox(
              height: 200, // Adjust height as needed
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.task.subtasks.length,
                itemBuilder: (context, index) {
                  final subtask = widget.task.subtasks[index];
                  return ListTile(
                    title: Text(subtask.title),
                    leading: Checkbox(
                      value: subtask.isCompleted,
                      onChanged: (bool? value) {
                        _toggleSubtaskCompletion(index);
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteSubtask(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addSubtask,
              child: Text('Add Subtask'),
            ),
            SizedBox(height: 16.0),
            // Notes Section
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            // Recurring Task Section
            Row(
              children: [
                Checkbox(
                  value: _isRecurring,
                  onChanged: (bool? value) {
                    setState(() {
                      _isRecurring = value!;
                    });
                  },
                ),
                Text('Recurring Task'),
              ],
            ),
            if (_isRecurring)
              DropdownButton<Recurrence>(
                value: _selectedRecurrence,
                onChanged: (Recurrence? newRecurrence) {
                  setState(() {
                    _selectedRecurrence = newRecurrence!;
                  });
                },
                items: Recurrence.values.map((Recurrence recurrence) {
                  return DropdownMenuItem<Recurrence>(
                    value: recurrence,
                    child: Text(recurrence.toString().split('.').last),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDueDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}
