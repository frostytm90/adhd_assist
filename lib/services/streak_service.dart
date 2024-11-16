import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StreakStats {
  final int currentStreak;
  final int bestStreak;
  final int totalDaysActive;
  final DateTime? lastActiveDate;
  final Map<String, int> weekdayCompletion;

  StreakStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalDaysActive,
    this.lastActiveDate,
    required this.weekdayCompletion,
  });

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'totalDaysActive': totalDaysActive,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'weekdayCompletion': weekdayCompletion,
      };

  factory StreakStats.fromJson(Map<String, dynamic> json) => StreakStats(
        currentStreak: json['currentStreak'] ?? 0,
        bestStreak: json['bestStreak'] ?? 0,
        totalDaysActive: json['totalDaysActive'] ?? 0,
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.parse(json['lastActiveDate'])
            : null,
        weekdayCompletion:
            Map<String, int>.from(json['weekdayCompletion'] ?? {}),
      );

  factory StreakStats.initial() => StreakStats(
        currentStreak: 0,
        bestStreak: 0,
        totalDaysActive: 0,
        weekdayCompletion: {
          'Monday': 0,
          'Tuesday': 0,
          'Wednesday': 0,
          'Thursday': 0,
          'Friday': 0,
          'Saturday': 0,
          'Sunday': 0,
        },
      );
}

class StreakService with ChangeNotifier {
  late Box<dynamic> _streakBox;
  StreakStats _stats = StreakStats.initial();
  
  StreakStats get stats => _stats;
  
  Future<void> initialize() async {
    _streakBox = await Hive.openBox('streaks');
    _loadData();
  }

  void _loadData() {
    final savedStats = _streakBox.get('stats');
    if (savedStats != null) {
      _stats = StreakStats.fromJson(Map<String, dynamic>.from(savedStats));
    }
    _checkStreakMaintenance();
  }

  void _saveData() {
    _streakBox.put('stats', _stats.toJson());
    notifyListeners();
  }

  void _checkStreakMaintenance() {
    if (_stats.lastActiveDate == null) return;

    final now = DateTime.now();
    final lastActive = _stats.lastActiveDate!;
    final difference = now.difference(lastActive).inDays;

    // If more than one day has passed, check if streak should be reset
    if (difference > 1) {
      _stats = StreakStats(
        currentStreak: 0,
        bestStreak: _stats.bestStreak,
        totalDaysActive: _stats.totalDaysActive,
        lastActiveDate: now,
        weekdayCompletion: _stats.weekdayCompletion,
      );
      _saveData();
    }
  }

  bool get isStreakAtRisk {
    if (_stats.lastActiveDate == null) return false;
    final now = DateTime.now();
    final lastActive = _stats.lastActiveDate!;
    return now.difference(lastActive).inHours >= 20; // Warning after 20 hours
  }

  void recordActivity() {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    
    if (_stats.lastActiveDate == null) {
      // First activity ever
      _stats = StreakStats(
        currentStreak: 1,
        bestStreak: 1,
        totalDaysActive: 1,
        lastActiveDate: now,
        weekdayCompletion: {
          ..._stats.weekdayCompletion,
          weekday: (_stats.weekdayCompletion[weekday] ?? 0) + 1,
        },
      );
    } else {
      final difference = now.difference(_stats.lastActiveDate!).inDays;
      
      if (difference == 0) {
        // Same day activity, just update weekday completion
        _stats = StreakStats(
          currentStreak: _stats.currentStreak,
          bestStreak: _stats.bestStreak,
          totalDaysActive: _stats.totalDaysActive,
          lastActiveDate: now,
          weekdayCompletion: {
            ..._stats.weekdayCompletion,
            weekday: (_stats.weekdayCompletion[weekday] ?? 0) + 1,
          },
        );
      } else if (difference == 1) {
        // Next day activity, increment streak
        final newStreak = _stats.currentStreak + 1;
        _stats = StreakStats(
          currentStreak: newStreak,
          bestStreak: newStreak > _stats.bestStreak ? newStreak : _stats.bestStreak,
          totalDaysActive: _stats.totalDaysActive + 1,
          lastActiveDate: now,
          weekdayCompletion: {
            ..._stats.weekdayCompletion,
            weekday: (_stats.weekdayCompletion[weekday] ?? 0) + 1,
          },
        );
      } else {
        // Streak broken, start new streak
        _stats = StreakStats(
          currentStreak: 1,
          bestStreak: _stats.bestStreak,
          totalDaysActive: _stats.totalDaysActive + 1,
          lastActiveDate: now,
          weekdayCompletion: {
            ..._stats.weekdayCompletion,
            weekday: (_stats.weekdayCompletion[weekday] ?? 0) + 1,
          },
        );
      }
    }
    
    _saveData();
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  Map<String, double> getWeekdayDistribution() {
    final total = _stats.weekdayCompletion.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return {};
    
    return _stats.weekdayCompletion.map(
      (key, value) => MapEntry(key, value / total),
    );
  }

  int getMostProductiveWeekday() {
    if (_stats.weekdayCompletion.isEmpty) return 1;
    
    var maxDay = 1;
    var maxValue = 0;
    
    _stats.weekdayCompletion.forEach((day, value) {
      if (value > maxValue) {
        maxValue = value;
        maxDay = _weekdayToNumber(day);
      }
    });
    
    return maxDay;
  }

  int _weekdayToNumber(String weekday) {
    switch (weekday) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 1;
    }
  }
}
