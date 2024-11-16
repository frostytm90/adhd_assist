import 'package:flutter/material.dart';
import '../models/task.dart'; // Import your Task model here

/// Get the color associated with a particular task category.
///
/// This function returns a [Color] value for the given [TaskCategory].
/// Colors are defined as follows:
/// - Work: Blue
/// - Personal: Green
/// - Wishlist: Purple
/// - All/Default: Grey
Color getCategoryColor(TaskCategory category) {
  debugPrint('Getting color for category: ${category.toString()}'); // Useful for debugging
  switch (category) {
    case TaskCategory.work:
      return Colors.blue;
    case TaskCategory.personal:
      return Colors.green;
    case TaskCategory.wishlist:
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
