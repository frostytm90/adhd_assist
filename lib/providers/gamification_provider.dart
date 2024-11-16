import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math' as math;
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
  int progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    this.isUnlocked = false,
    this.progress = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'requiredCount': requiredCount,
        'isUnlocked': isUnlocked,
        'progress': progress,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        icon: json['icon'],
        requiredCount: json['requiredCount'],
        isUnlocked: json['isUnlocked'] ?? false,
        progress: json['progress'] ?? 0,
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
  int get streak => _streakService.stats.currentStreak;
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
          id: 'focus_master',
          title: 'Focus Master',
          description: 'Complete 3 tasks without switching between them',
          icon: '🧠',
          requiredCount: 3,
        ),
        Achievement(
          id: 'time_manager',
          title: 'Time Manager',
          description: 'Complete tasks before their due dates 5 times',
          icon: '⏰',
          requiredCount: 5,
        ),
        Achievement(
          id: 'routine_builder',
          title: 'Routine Builder',
          description: 'Complete morning routine tasks for 5 days',
          icon: '🌅',
          requiredCount: 5,
        ),
        Achievement(
          id: 'priority_ninja',
          title: 'Priority Ninja',
          description: 'Complete 10 high-priority tasks',
          icon: '⚡',
          requiredCount: 10,
        ),
        Achievement(
          id: 'streak_champion',
          title: 'Streak Champion',
          description: 'Maintain a 7-day task completion streak',
          icon: '🔥',
          requiredCount: 7,
        ),
        Achievement(
          id: 'mindful_master',
          title: 'Mindful Master',
          description: 'Take breaks between tasks 10 times',
          icon: '🧘',
          requiredCount: 10,
        ),
        Achievement(
          id: 'organization_guru',
          title: 'Organization Guru',
          description: 'Categorize and complete 15 tasks',
          icon: '📋',
          requiredCount: 15,
        ),
        Achievement(
          id: 'momentum_keeper',
          title: 'Momentum Keeper',
          description: 'Complete tasks on 5 consecutive days',
          icon: '🚀',
          requiredCount: 5,
        ),
        Achievement(
          id: 'dopamine_hunter',
          title: 'Dopamine Hunter',
          description: 'Complete 3 challenging tasks in one day',
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
    await _checkAchievements(task);

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
    // First task achievement
    _updateAchievementProgress('first_task', 1);

    // Priority ninja achievement
    if (task.priority == TaskPriority.high) {
      _updateAchievementProgress('priority_ninja', 1);
    }

    // Time manager achievement
    if (task.dueDate != null && DateTime.now().isBefore(task.dueDate!)) {
      _updateAchievementProgress('time_manager', 1);
    }

    // Streak champion achievement
    _updateAchievementProgress('streak_champion', _streakService.stats.currentStreak);

    // Momentum keeper achievement
    if (_streakService.stats.currentStreak >= 1) {
      _updateAchievementProgress('momentum_keeper', _streakService.stats.currentStreak);
    }

    // Organization guru achievement
    if (task.category != TaskCategory.all) {
      _updateAchievementProgress('organization_guru', 1);
    }

    // Focus master achievement (track in task completion sequence)
    if (_lastTaskDate != null && 
        DateTime.now().difference(_lastTaskDate!).inMinutes < 30) {
      _updateAchievementProgress('focus_master', 1);
    } else {
      _resetAchievementProgress('focus_master');
    }

    // Routine builder achievement
    final now = DateTime.now();
    if (now.hour < 10) { // Before 10 AM
      _updateAchievementProgress('routine_builder', 1);
    }

    // Dopamine hunter achievement
    if (task.difficulty == TaskDifficulty.hard) {
      _updateAchievementProgress('dopamine_hunter', 1);
    }

    _lastTaskDate = DateTime.now();
    _saveData();
  }

  void _updateAchievementProgress(String id, int increment) {
    final achievement = _achievements.firstWhere((a) => a.id == id);
    if (!achievement.isUnlocked) {
      if (increment == achievement.requiredCount) {
        achievement.progress = achievement.requiredCount;
        _unlockAchievement(id);
      } else {
        achievement.progress = math.min(
          achievement.progress + increment,
          achievement.requiredCount
        );
        if (achievement.progress >= achievement.requiredCount) {
          _unlockAchievement(id);
        }
      }
      _saveData();
    }
  }

  void _resetAchievementProgress(String id) {
    final achievement = _achievements.firstWhere((a) => a.id == id);
    if (!achievement.isUnlocked) {
      achievement.progress = 0;
      _saveData();
    }
  }

  Future<void> _unlockAchievement(String id) async {
    final achievement = _achievements.firstWhere((a) => a.id == id);
    
    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      await _soundService.playAchievementUnlocked();
      _saveData();
    }
  }

  double getLevelProgress() {
    final nextLevelPoints = getPointsForNextLevel();
    final currentLevelPoints = 100 * ((_level - 1) * 1.5).round();
    final pointsInCurrentLevel = _points - currentLevelPoints;
    final pointsNeededForNextLevel = nextLevelPoints - currentLevelPoints;
    return pointsInCurrentLevel / pointsNeededForNextLevel;
  }
}
