// models/task.dart
import 'package:uuid/uuid.dart';

enum TaskCategory { all, work, personal, wishlist }
enum TaskPriority { low, medium, high }
enum Recurrence { daily, weekly, monthly }

class Task {
  String id;
  String title;
  String description;
  TaskCategory category;
  TaskPriority priority;
  DateTime? dueDate;
  bool isCompleted;
  String? notes;
  bool isRecurring;
  Recurrence? recurrence;

  // Generate unique ID using UUID
  Task({
    String? id,
    required this.title,
    required this.description,
    this.category = TaskCategory.all,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.notes,
    this.isRecurring = false,
    this.recurrence,
  }) : id = id ?? Uuid().v4();

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id'],
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

  // Generate a list of sample tasks for testing
  static List<Task> generateMockTasks() {
    return [
      Task(
        title: 'Work Meeting',
        description: 'Meeting with the team to discuss project updates',
        category: TaskCategory.work,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(Duration(days: 1)),
      ),
      Task(
        title: 'Grocery Shopping',
        description: 'Buy ingredients for dinner',
        category: TaskCategory.personal,
        priority: TaskPriority.medium,
      ),
      Task(
        title: 'Read a Book',
        description: 'Read 30 pages of a new book',
        category: TaskCategory.wishlist,
        priority: TaskPriority.low,
        isRecurring: true,
        recurrence: Recurrence.daily,
      ),
    ];
  }
}
