// models/task.dart
enum TaskCategory { all, work, personal, wishlist }
enum TaskPriority { low, medium, high }

class Task {
  String title;
  String description;
  TaskCategory category;
  TaskPriority priority;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.category = TaskCategory.all,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
  });
}
