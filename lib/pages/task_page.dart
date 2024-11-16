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
        final allTasks = category == TaskCategory.all
            ? taskProvider.tasks
            : taskProvider.tasks.where((task) => task.category == category).toList();

        final activeTasks = allTasks.where((task) => !task.isCompleted).toList();
        final completedTasks = allTasks.where((task) => task.isCompleted).toList();

        if (allTasks.isEmpty) {
          return const Center(
            child: Text('No tasks yet'),
          );
        }

        return ListView(
          children: [
            // Active tasks
            ...activeTasks.map((task) => _buildTaskCard(context, task, taskProvider)),
            
            // Completed tasks section (if any)
            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    'Completed (${completedTasks.length})',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  initiallyExpanded: false,
                  children: completedTasks
                      .map((task) => _buildCompactTaskCard(context, task, taskProvider))
                      .toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider taskProvider) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        taskProvider.deleteTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
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
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              if (value != null) {
                if (task.isRecurring) {
                  taskProvider.completeRecurringTask(task);
                } else {
                  taskProvider.completeTask(task);
                }
              }
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) Text(task.description),
              if (task.dueDate != null)
                Text(
                  'Due: ${DateFormat.yMMMd().format(task.dueDate!)}',
                  style: TextStyle(
                    color: task.dueDate!.isBefore(DateTime.now()) ? Colors.red : null,
                  ),
                ),
              if (task.isRecurring)
                Text(
                  'Repeats: ${task.recurrence.toString().split('.').last}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPriorityIcon(task.priority),
                color: _getPriorityColor(task.priority),
              ),
              if (task.difficulty == TaskDifficulty.hard)
                const Icon(
                  Icons.whatshot,
                  color: Colors.orange,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTaskCard(BuildContext context, Task task, TaskProvider taskProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: IconButton(
          icon: const Icon(Icons.restore, size: 20),
          onPressed: () {
            taskProvider.updateTask(task..isCompleted = false);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            taskProvider.deleteTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    taskProvider.addTask(task);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.arrow_downward;
    }
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
