import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

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
  late TaskPriority _selectedPriority;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedPriority = widget.task.priority;
    _selectedDate = widget.task.dueDate;
  }

  // Method to update the task and save the changes
  void _updateTask() {
    widget.task.title = _titleController.text;
    widget.task.description = _descriptionController.text;
    widget.task.priority = _selectedPriority;
    widget.task.dueDate = _selectedDate;
    widget.onEdit();  // Notify the parent that the task was edited
    Navigator.of(context).pop();  // Go back to the previous screen
  }

  // Method to delete the task and handle navigation
  void _confirmDeleteTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete();  // Notify the parent that the task was deleted
                Navigator.of(context).pop();  // Close the confirmation dialog
                Navigator.of(context).maybePop();  // Navigate back to the task list page
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),  // Save edits
            onPressed: _updateTask,
          ),
          IconButton(
            icon: Icon(Icons.delete),  // Delete task
            onPressed: _confirmDeleteTask,  // Confirm deletion before executing
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
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
            SizedBox(height: 16.0),
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
