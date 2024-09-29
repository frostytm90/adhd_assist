enum TaskCategory { all, work, personal, wishlist }
enum TaskPriority { low, medium, high }

class Task {
  String title;
  String description;
  TaskCategory category;
  TaskPriority priority; // New field for task priority
  DateTime? dueDate; // New field for due date
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.category = TaskCategory.all,
    this.priority = TaskPriority.medium, // Default priority is medium
    this.dueDate,
    this.isCompleted = false,
  });
}
