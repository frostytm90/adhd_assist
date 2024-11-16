import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'gamification_provider.dart';

class TaskProvider with ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  TaskCategory _selectedCategory = TaskCategory.all;
  GamificationProvider? _gamificationProvider;

  // Getters
  List<Task> get tasks => _selectedCategory == TaskCategory.all
      ? _tasks
      : _tasks.where((task) => task.category == _selectedCategory).toList();

  TaskCategory get selectedCategory => _selectedCategory;

  void setGamificationProvider(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  Future<void> initHive() async {
    // Register the TaskAdapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskPriorityAdapter());
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

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    
    if (task.isCompleted) {
      // Notify gamification provider
      _gamificationProvider?.onTaskCompleted(task);
    }
    
    await task.save();
    _loadTasks();
  }

  void setSelectedCategory(TaskCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Get tasks grouped by category
  Map<TaskCategory, List<Task>> getTasksByCategory() {
    final Map<TaskCategory, List<Task>> groupedTasks = {};
    for (var category in TaskCategory.values) {
      if (category != TaskCategory.all) {
        groupedTasks[category] = _tasks
            .where((task) => task.category == category && !task.isCompleted)
            .toList();
      }
    }
    return groupedTasks;
  }

  // Get tasks due today
  List<Task> getTasksDueToday() {
    final now = DateTime.now();
    return _tasks
        .where((task) =>
            !task.isCompleted &&
            task.dueDate != null &&
            task.dueDate!.year == now.year &&
            task.dueDate!.month == now.month &&
            task.dueDate!.day == now.day)
        .toList();
  }

  // Get overdue tasks
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks
        .where((task) =>
            !task.isCompleted &&
            task.dueDate != null &&
            task.dueDate!.isBefore(now))
        .toList();
  }
}
