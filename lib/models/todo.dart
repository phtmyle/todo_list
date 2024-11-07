import 'package:flutter/foundation.dart';

class Todo extends ChangeNotifier {
  final String id;
  final String title;
  final DateTime dueDate; // Changed to DateTime
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });

  void toggleCompleted() {
    isCompleted = !isCompleted;
    notifyListeners();
  }
}
