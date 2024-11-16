// models/task.dart
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskCategory {
  @HiveField(0)
  all,
  @HiveField(1)
  daily,  // For routine tasks and daily activities
  @HiveField(2)
  important,  // For high-priority tasks
  @HiveField(3)
  goals  // For long-term objectives and personal development
}

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high
}

@HiveType(typeId: 2)
enum Recurrence {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly
}

@HiveType(typeId: 4)
enum TaskDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  TaskCategory category;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  DateTime? dueDate;
  
  @HiveField(6)
  TaskPriority priority;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime? completedAt;
  
  @HiveField(9)
  Recurrence? recurrence;

  @HiveField(10)
  TaskDifficulty difficulty;

  bool get isRecurring => recurrence != null;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.category,
    this.isCompleted = false,
    this.dueDate,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.completedAt,
    this.recurrence,
    this.difficulty = TaskDifficulty.medium,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

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
      'recurrence': recurrence?.index,
      'difficulty': difficulty.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
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
      recurrence: json['recurrence'] != null ? Recurrence.values[json['recurrence']] : null,
      difficulty: TaskDifficulty.values[json['difficulty'] ?? TaskDifficulty.medium.index],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  // Generate a list of sample tasks for testing
  static List<Task> generateMockTasks() {
    return [
      Task(
        title: 'Work Meeting',
        description: 'Meeting with the team to discuss project updates',
        category: TaskCategory.important,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(Duration(days: 1)),
      ),
      Task(
        title: 'Grocery Shopping',
        description: 'Buy ingredients for dinner',
        category: TaskCategory.daily,
        priority: TaskPriority.medium,
      ),
      Task(
        title: 'Read a Book',
        description: 'Read 30 pages of a new book',
        category: TaskCategory.goals,
        priority: TaskPriority.low,
        recurrence: Recurrence.daily,
      ),
    ];
  }
}
