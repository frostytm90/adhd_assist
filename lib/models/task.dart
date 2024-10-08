// models/task.dart
enum TaskCategory { all, work, personal, wishlist }
enum TaskPriority { low, medium, high }
enum Recurrence { daily, weekly, monthly }

class Task {
  String title;
  String description;
  TaskCategory category;
  TaskPriority priority;
  DateTime? dueDate;
  bool isCompleted;
  String? notes;
  bool isRecurring;
  Recurrence? recurrence;

  Task({
    required this.title,
    required this.description,
    this.category = TaskCategory.all,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.notes,
    this.isRecurring = false,
    this.recurrence,
  });

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.index,
      'priority': priority.index,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
      'isRecurring': isRecurring,
      'recurrence': recurrence?.index,
    };
  }

  // Convert JSON to Task
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      category: TaskCategory.values[json['category']],
      priority: TaskPriority.values[json['priority']],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'],
      notes: json['notes'],
      isRecurring: json['isRecurring'],
      recurrence: json['recurrence'] != null ? Recurrence.values[json['recurrence']] : null,
    );
  }
}
