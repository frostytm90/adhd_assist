import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/sound_service.dart';
import '../services/streak_service.dart';

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
  final SoundService _soundService = SoundService();
  final StreakService _streakService = StreakService();
  
  List<Achievement> _achievements = [];
  int _points = 0;
  int _level = 1;
  int _tasksCompletedToday = 0;
  DateTime? _lastTaskDate;

  // Getters
  List<Achievement> get achievements => _achievements;
  int get points => _points;
  int get level => _level;
  StreakStats get streakStats => _streakService.stats;
  bool get isStreakAtRisk => _streakService.isStreakAtRisk;

  // Points required for each level (increases exponentially)
  int getPointsForNextLevel() => 100 * (_level * 1.5).round();

  // Initialize Hive and load saved data
  Future<void> initHive() async {
    await Hive.initFlutter();
    _gameBox = await Hive.openBox('gamification');
    await _streakService.initialize();
    await _soundService.initialize();
    _loadData();
    _initializeAchievements();
    _resetDailyTasksIfNeeded();
  }

  void _loadData() {
    _points = _gameBox.get('points', defaultValue: 0);
    _level = _gameBox.get('level', defaultValue: 1);
    _tasksCompletedToday = _gameBox.get('tasksCompletedToday', defaultValue: 0);
    final lastTaskStr = _gameBox.get('lastTaskDate');
    _lastTaskDate = lastTaskStr != null ? DateTime.parse(lastTaskStr) : null;
    
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
    _gameBox.put('tasksCompletedToday', _tasksCompletedToday);
    if (_lastTaskDate != null) {
      _gameBox.put('lastTaskDate', _lastTaskDate!.toIso8601String());
    }
    _gameBox.put('achievements',
        _achievements.map((a) => a.toJson()).toList());
    notifyListeners();
  }

  void _resetDailyTasksIfNeeded() {
    if (_lastTaskDate == null) return;
    
    final now = DateTime.now();
    if (!_isSameDay(now, _lastTaskDate!)) {
      _tasksCompletedToday = 0;
      _saveData();
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
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
        Achievement(
          id: 'consistency_king',
          title: 'Consistency King',
          description: 'Complete tasks on 5 consecutive days',
          icon: '👑',
          requiredCount: 5,
        ),
        Achievement(
          id: 'weekend_warrior',
          title: 'Weekend Warrior',
          description: 'Complete 3 tasks on a weekend',
          icon: '🎮',
          requiredCount: 3,
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
    final currentStreak = _streakService.stats.currentStreak;
    if (currentStreak > 0) {
      points += (currentStreak * 2).clamp(0, 20); // Max 20 bonus points from streak
    }

    return points;
  }

  Future<void> onTaskCompleted(Task task) async {
    final now = DateTime.now();
    
    // Award points
    final earnedPoints = _calculateTaskPoints(task);
    _points += earnedPoints;

    // Update daily tasks count
    if (_lastTaskDate == null || !_isSameDay(now, _lastTaskDate!)) {
      _tasksCompletedToday = 1;
    } else {
      _tasksCompletedToday++;
    }
    _lastTaskDate = now;

    // Record streak activity
    _streakService.recordActivity();

    // Play completion sound
    await _soundService.playTaskComplete();

    // Check level up
    final oldLevel = _level;
    while (_points >= getPointsForNextLevel()) {
      _level++;
    }
    if (_level > oldLevel) {
      await _soundService.playLevelUp();
    }

    // Check achievements
    final unlockedBefore = _achievements.where((a) => a.isUnlocked).length;
    await _checkAchievements(task);
    final unlockedAfter = _achievements.where((a) => a.isUnlocked).length;
    
    if (unlockedAfter > unlockedBefore) {
      await _soundService.playAchievementUnlocked();
    }

    // Check streak milestones
    if (_streakService.stats.currentStreak == 3 || 
        _streakService.stats.currentStreak == 7 ||
        _streakService.stats.currentStreak == 14 ||
        _streakService.stats.currentStreak == 30) {
      await _soundService.playStreakMilestone();
    }

    _saveData();
  }

  Future<void> _checkAchievements(Task task) async {
    final stats = _streakService.stats;
    
    // First Task
    _unlockAchievement('first_task');

    // Productive Day
    if (_tasksCompletedToday >= 5) {
      _unlockAchievement('productive_day');
    }

    // Streak Master
    if (stats.currentStreak >= 7) {
      _unlockAchievement('streak_master');
    }

    // Task Warrior (total tasks completed)
    if (_gameBox.get('totalTasksCompleted', defaultValue: 0) >= 50) {
      _unlockAchievement('task_warrior');
    }

    // Early Bird
    if (DateTime.now().hour < 9) {
      _unlockAchievement('early_bird');
    }

    // Priority Master
    if (task.priority == TaskPriority.high) {
      final highPriorityCount = _gameBox.get('highPriorityCount', defaultValue: 0) + 1;
      _gameBox.put('highPriorityCount', highPriorityCount);
      if (highPriorityCount >= 10) {
        _unlockAchievement('priority_master');
      }
    }

    // Consistency King
    if (stats.currentStreak >= 5) {
      _unlockAchievement('consistency_king');
    }

    // Weekend Warrior
    if (DateTime.now().weekday >= 6 && _tasksCompletedToday >= 3) {
      _unlockAchievement('weekend_warrior');
    }
  }

  void _unlockAchievement(String id) {
    final achievement = _achievements.firstWhere(
      (a) => a.id == id && !a.isUnlocked,
      orElse: () => Achievement(
        id: '',
        title: '',
        description: '',
        icon: '',
        requiredCount: 0,
        isUnlocked: true,
      ),
    );
    
    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      _saveData();
    }
  }

  double getLevelProgress() {
    final pointsForCurrentLevel = getPointsForNextLevel();
    final previousLevelPoints = (100 * ((_level - 1) * 1.5)).round();
    final currentPoints = _points - previousLevelPoints;
    final requiredPoints = pointsForCurrentLevel - previousLevelPoints;
    return currentPoints / requiredPoints;
  }
}
