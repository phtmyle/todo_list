import 'package:flutter/foundation.dart';

import '../models/todo.dart';

class TodoListViewModel extends ChangeNotifier {
  final List<Todo> _todos;

  TodoListViewModel(this._todos);

  List<Todo> getTodos() {
    return _todos;
  }

  // Get todos by category
  List<Todo> getTodosByCategory(String category) {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    switch (category) {
      case 'Today':
        return _todos
            .where((todo) =>
                !todo.isCompleted &&
                todo.dueDate != null &&
                todo.dueDate!.year == now.year &&
                todo.dueDate!.month == now.month &&
                todo.dueDate!.day == now.day)
            .toList();
      case 'Tomorrow':
        return _todos
            .where((todo) =>
                !todo.isCompleted &&
                todo.dueDate != null &&
                todo.dueDate!.year == tomorrow.year &&
                todo.dueDate!.month == tomorrow.month &&
                todo.dueDate!.day == tomorrow.day)
            .toList();
      case 'Upcoming':
        return _todos
            .where((todo) =>
                !todo.isCompleted &&
                (todo.dueDate == null || todo.dueDate!.isAfter(now)))
            .toList();
      default: // 'All'
        return _todos;
    }
  }

  // Add a new todo
  void addTodo(Todo todo) {
    _todos.add(todo);
  }

  // Remove a todo
  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }

  // Mark a todo as completed
  void completeTodo(String id) {
    final todo = _todos.firstWhere((todo) => todo.id == id);
    todo.isCompleted = true;
  }
    // Update the status of a todo
  void updateTodoStatus(String id, bool isCompleted) {
    final todo = _todos.firstWhere((todo) => todo.id == id);
    todo.isCompleted = isCompleted;
    notifyListeners(); // Notify listeners to update the UI
  }
}
