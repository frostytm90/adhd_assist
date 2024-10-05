import 'package:flutter/material.dart';
import '../models/task.dart'; // Import the Task model for TaskCategory enum

Color getCategoryColor(TaskCategory category) {
  switch (category) {
    case TaskCategory.work:
      return Colors.blue;
    case TaskCategory.personal:
      return Colors.green;
    case TaskCategory.wishlist:
      return Colors.orange;
    case TaskCategory.all:
    default:
      return Colors.grey;
  }
}
