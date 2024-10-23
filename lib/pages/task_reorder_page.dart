import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskReorderPage extends StatefulWidget {
  final List<Task> tasks;

  const TaskReorderPage({super.key, required this.tasks});

  @override
  _TaskReorderPageState createState() => _TaskReorderPageState();
}

class _TaskReorderPageState extends State<TaskReorderPage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Tasks'),
      ),
      body: ReorderableListView(
        key: const ValueKey('reorderableListView'),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final task = _tasks.removeAt(oldIndex);
            _tasks.insert(newIndex, task);
          });
        },
        children: [
          for (int index = 0; index < _tasks.length; index++)
            ListTile(
              key: ValueKey('reorderTask_${_tasks[index].title}_$index'),
              title: Text(_tasks[index].title),
              trailing: const Icon(Icons.drag_handle),
            )
        ],
      ),
    );
  }
}
