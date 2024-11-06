import 'package:flutter/cupertino.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TodolistViewModel extends ChangeNotifier {
  final List<Todo> _todos = [];
  final NotificationService _notificationService = NotificationService();

  List<Todo> get todos => _todos;

  void addTodo(String title, DateTime dueDate) {
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      dueDate: dueDate,
    );
    _todos.add(newTodo);
    notifyListeners();
    _notificationService.scheduleNotification(
      newTodo.id.hashCode,
      'Todo Reminder',
      'Don\'t forget to complete: ${newTodo.title}',
      tz.TZDateTime.from(dueDate, tz.local),
    );
  }

  void markAsCompleted(String id) {
    final todo = _todos.firstWhere((todo) => todo.id == id);
    todo.isCompleted = true;
    notifyListeners();
  }

  List<Todo> getTodoByCategory(String category) {
    final now = DateTime.now();
    switch (category) {
      case 'Today':
        return _todos
            .where((todo) =>
                todo.dueDate.year == now.year &&
                todo.dueDate.month == now.month &&
                todo.dueDate.day == now.day)
            .toList();
      case 'Tomorrow':
        return _todos
            .where((todo) =>
                todo.dueDate.year == now.year &&
                todo.dueDate.month == now.month &&
                todo.dueDate.day == now.day + 1)
            .toList();
      case 'Upcoming':
        return _todos
            .where((todo) =>
                todo.dueDate.isAfter(now.add(const Duration(days: 1))))
            .toList();
      default:
        return _todos;
    }
  }
}
