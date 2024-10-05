// models/task.dart
enum TaskCategory { all, work, personal, wishlist }
enum TaskPriority { low, medium, high }

class Subtask {
  String title;
  bool isCompleted;

  Subtask({required this.title, this.isCompleted = false});
}

class Task {
  String title;
  String description;
  TaskCategory category;
  TaskPriority priority;
  DateTime? dueDate;
  bool isCompleted;
  List<Subtask> subtasks;  // Subtasks field
  String? notes;           // Notes field
  bool isRecurring;        // Field to indicate if the task is recurring
  Recurrence? recurrence;  // Recurrence pattern (daily, weekly, etc.)

  Task({
    required this.title,
    required this.description,
    this.category = TaskCategory.all,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.subtasks = const [],   // Initialize with empty subtasks
    this.notes = '',            // Default empty notes
    this.isRecurring = false,   // Default not recurring
    this.recurrence,            // Recurrence pattern, null by default
  });
}

// Add an enum for recurrence
enum Recurrence { daily, weekly, monthly }
