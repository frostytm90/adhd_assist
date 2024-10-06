import 'package:flutter/material.dart';
import '../models/task.dart'; // Import your Task model here

Color getCategoryColor(TaskCategory category) {
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
