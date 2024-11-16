import 'package:flutter/material.dart';
import '../models/task.dart';

/// Get the color associated with a particular task category.
///
/// This function returns a [Color] value for the given [TaskCategory].
/// Colors are defined as follows:
/// - Daily: Green (for routine tasks)
/// - Important: Red (for high-priority tasks)
/// - Goals: Blue (for long-term objectives)
/// - All: Grey (default view)
Color getCategoryColor(TaskCategory category) {
  debugPrint('Getting color for category: ${category.toString()}'); // Useful for debugging
  switch (category) {
    case TaskCategory.daily:
      return Colors.green;
    case TaskCategory.important:
      return Colors.red;
    case TaskCategory.goals:
      return Colors.blue;
    case TaskCategory.all:
      return Colors.grey;
  }
}
