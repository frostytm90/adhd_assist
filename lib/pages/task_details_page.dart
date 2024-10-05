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

  void _updateTask() {
    setState(() {
      widget.task.title = _titleController.text;
      widget.task.description = _descriptionController.text;
      widget.task.priority = _selectedPriority;
      widget.task.dueDate = _selectedDate;
    });

    widget.onEdit();  // Notify parent of changes
    Navigator.of(context).pop();  // Go back to the previous screen
  }

  Future<DateTime?> _pickDueDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
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
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Task Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            // Task Priority
            DropdownButtonFormField<TaskPriority>(
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
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Due Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No due date set'
                        : 'Due Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                  ),
                ),
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
}
