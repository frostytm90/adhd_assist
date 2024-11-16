import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import 'add_task_dialog.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TaskCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          bottom: TabBar(
            isScrollable: true,
            tabs: TaskCategory.values.map((category) {
              return Tab(
                text: category.toString().split('.').last,
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: TaskCategory.values.map((category) {
            return _TaskList(category: category);
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddTaskDialog(
                onTaskAdded: (Task newTask) {
                  context.read<TaskProvider>().addTask(newTask);
                },
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final TaskCategory category;

  const _TaskList({required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.getTasksByCategory(category);

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              'No tasks in ${category.toString().split('.').last}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                taskProvider.deleteTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${task.title} deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        taskProvider.addTask(task);
                      },
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      taskProvider.toggleTaskCompletion(task.id);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description),
                      if (task.dueDate != null)
                        Text(
                          'Due: ${DateFormat.yMMMd().format(task.dueDate!)}',
                          style: TextStyle(
                            color: task.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : null,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (task.isRecurring)
                        const Icon(Icons.repeat, size: 20),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getPriorityColor(task.priority),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}
