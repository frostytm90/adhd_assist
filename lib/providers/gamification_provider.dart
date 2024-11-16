import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredCount;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'requiredCount': requiredCount,
        'isUnlocked': isUnlocked,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        icon: json['icon'],
        requiredCount: json['requiredCount'],
        isUnlocked: json['isUnlocked'] ?? false,
      );
}

class GamificationProvider with ChangeNotifier {
  late Box<dynamic> _gameBox;
  List<Achievement> _achievements = [];
  int _points = 0;
  int _level = 1;
  int _streak = 0;
  DateTime? _lastCompletedTask;

  // Getters
  List<Achievement> get achievements => _achievements;
  int get points => _points;
  int get level => _level;
  int get streak => _streak;

  // Points required for each level (increases exponentially)
  int getPointsForNextLevel() => 100 * (_level * 1.5).round();

  // Initialize Hive and load saved data
  Future<void> initHive() async {
    _gameBox = await Hive.openBox('gamification');
    _loadData();
    _initializeAchievements();
  }

  void _loadData() {
    _points = _gameBox.get('points', defaultValue: 0);
    _level = _gameBox.get('level', defaultValue: 1);
    _streak = _gameBox.get('streak', defaultValue: 0);
    final lastCompleted = _gameBox.get('lastCompletedTask');
    _lastCompletedTask = lastCompleted != null ? DateTime.parse(lastCompleted) : null;
    
    final savedAchievements = _gameBox.get('achievements');
    if (savedAchievements != null) {
      _achievements = (savedAchievements as List)
          .map((e) => Achievement.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  void _saveData() {
    _gameBox.put('points', _points);
    _gameBox.put('level', _level);
    _gameBox.put('streak', _streak);
    if (_lastCompletedTask != null) {
      _gameBox.put('lastCompletedTask', _lastCompletedTask!.toIso8601String());
    }
    _gameBox.put('achievements',
        _achievements.map((a) => a.toJson()).toList());
  }

  void _initializeAchievements() {
    if (_achievements.isEmpty) {
      _achievements = [
        Achievement(
          id: 'first_task',
          title: 'First Step',
          description: 'Complete your first task',
          icon: '🎯',
          requiredCount: 1,
        ),
        Achievement(
          id: 'productive_day',
          title: 'Productive Day',
          description: 'Complete 5 tasks in one day',
          icon: '⭐',
          requiredCount: 5,
        ),
        Achievement(
          id: 'streak_master',
          title: 'Streak Master',
          description: 'Maintain a 7-day streak',
          icon: '🔥',
          requiredCount: 7,
        ),
        Achievement(
          id: 'task_warrior',
          title: 'Task Warrior',
          description: 'Complete 50 tasks total',
          icon: '⚔️',
          requiredCount: 50,
        ),
        Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Complete a task before 9 AM',
          icon: '🌅',
          requiredCount: 1,
        ),
        Achievement(
          id: 'priority_master',
          title: 'Priority Master',
          description: 'Complete 10 high-priority tasks',
          icon: '⚡',
          requiredCount: 10,
        ),
      ];
      _saveData();
    }
  }

  // Calculate points based on task properties
  int _calculateTaskPoints(Task task) {
    int points = 10; // Base points

    // Priority bonus
    switch (task.priority) {
      case TaskPriority.high:
        points += 15;
        break;
      case TaskPriority.medium:
        points += 10;
        break;
      case TaskPriority.low:
        points += 5;
        break;
    }

    // Early completion bonus (if completed before due date)
    if (task.dueDate != null && DateTime.now().isBefore(task.dueDate!)) {
      points += 10;
    }

    // Streak bonus
    if (_streak > 0) {
      points += (_streak * 2).clamp(0, 20); // Max 20 bonus points from streak
    }

    return points;
  }

  void onTaskCompleted(Task task) {
    // Award points
    final earnedPoints = _calculateTaskPoints(task);
    _points += earnedPoints;

    // Update streak
    final now = DateTime.now();
    if (_lastCompletedTask != null) {
      final difference = now.difference(_lastCompletedTask!).inDays;
      if (difference == 1) {
        _streak++;
      } else if (difference > 1) {
        _streak = 1;
      }
    } else {
      _streak = 1;
    }
    _lastCompletedTask = now;

    // Check level up
    while (_points >= getPointsForNextLevel()) {
      _level++;
    }

    // Check achievements
    _checkAchievements(task);

    _saveData();
    notifyListeners();
  }

  void _checkAchievements(Task task) {
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked) {
        switch (achievement.id) {
          case 'first_task':
            achievement.isUnlocked = true;
            break;
          case 'productive_day':
            // Implementation needed: track daily task count
            break;
          case 'streak_master':
            if (_streak >= achievement.requiredCount) {
              achievement.isUnlocked = true;
            }
            break;
          case 'early_bird':
            if (DateTime.now().hour < 9) {
              achievement.isUnlocked = true;
            }
            break;
          case 'priority_master':
            if (task.priority == TaskPriority.high) {
              // Implementation needed: track high priority task count
            }
            break;
        }
      }
    }
  }

  // Get progress towards next level (0.0 to 1.0)
  double getLevelProgress() {
    final pointsForNextLevel = getPointsForNextLevel();
    final pointsInCurrentLevel = _points - (pointsForNextLevel - 100);
    return pointsInCurrentLevel / pointsForNextLevel;
  }
}
