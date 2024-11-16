import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final String _boxName = 'tasks';
  
  List<Task> get tasks => _tasks;
  
  List<Task> getTasksByCategory(TaskCategory category) {
    if (category == TaskCategory.all) {
      return _tasks;
    }
    return _tasks.where((task) => task.category == category).toList();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskCategoryAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(RecurrenceAdapter());
    
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final box = await Hive.openBox<Task>(_boxName);
    _tasks = box.values.toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final box = await Hive.openBox<Task>(_boxName);
    await box.put(task.id, task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final box = await Hive.openBox<Task>(_boxName);
    await box.put(task.id, task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final box = await Hive.openBox<Task>(_boxName);
    await box.delete(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((task) => task.id == taskId);
    task.isCompleted = !task.isCompleted;
    
    if (task.isRecurring && task.isCompleted) {
      final nextTask = Task(
        title: task.title,
        description: task.description,
        category: task.category,
        priority: task.priority,
        isRecurring: true,
        recurrence: task.recurrence,
        dueDate: _calculateNextDueDate(task),
      );
      await addTask(nextTask);
    }
    
    await updateTask(task);
  }

  DateTime? _calculateNextDueDate(Task task) {
    if (task.dueDate == null || task.recurrence == null) return null;

    switch (task.recurrence!) {
      case Recurrence.daily:
        return task.dueDate!.add(const Duration(days: 1));
      case Recurrence.weekly:
        return task.dueDate!.add(const Duration(days: 7));
      case Recurrence.monthly:
        return DateTime(
          task.dueDate!.year,
          task.dueDate!.month + 1,
          task.dueDate!.day,
        );
    }
  }
}
