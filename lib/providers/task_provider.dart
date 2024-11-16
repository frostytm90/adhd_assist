import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'gamification_provider.dart';
import '../services/sound_service.dart';

class TaskProvider with ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  GamificationProvider? _gamificationProvider;
  final _soundService = SoundService();

  // Getters
  List<Task> get tasks => _tasks;

  void setGamificationProvider(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  Future<void> initHive() async {
    // Register the TaskAdapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecurrenceAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TaskDifficultyAdapter());
    }

    // Open the box
    _taskBox = await Hive.openBox<Task>('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskBox.add(task);
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await task.save();
    _loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
    _loadTasks();
  }

  Future<void> completeTask(Task task) async {
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    await updateTask(task);
    await _soundService.playTaskComplete();
    _gamificationProvider?.onTaskCompleted(task);
  }

  Future<void> completeRecurringTask(Task task) async {
    // Mark current task as completed
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    await updateTask(task);
    
    // Create next occurrence
    final nextTask = Task(
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      difficulty: task.difficulty,
      dueDate: _calculateNextDueDate(task.dueDate, task.recurrence),
      recurrence: task.recurrence,
    );
    
    await addTask(nextTask);
    await _soundService.playTaskComplete();
    _gamificationProvider?.onTaskCompleted(task);
  }

  DateTime? _calculateNextDueDate(DateTime? currentDueDate, Recurrence? recurrence) {
    if (currentDueDate == null || recurrence == null) return null;

    switch (recurrence) {
      case Recurrence.daily:
        return currentDueDate.add(const Duration(days: 1));
      case Recurrence.weekly:
        return currentDueDate.add(const Duration(days: 7));
      case Recurrence.monthly:
        return DateTime(
          currentDueDate.year,
          currentDueDate.month + 1,
          currentDueDate.day,
        );
    }
  }
}
