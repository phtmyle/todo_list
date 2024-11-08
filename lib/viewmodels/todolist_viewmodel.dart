import 'package:flutter/cupertino.dart';

import '../models/todo.dart';

class TodoListViewModel extends ChangeNotifier {
  final List<Todo> _todos;

  // TodoListViewModel(this._todos);
  TodoListViewModel()
      : _todos = [
          Todo(
            id: '1',
            title: 'Complete project report',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            remindMe: true,
            isCompleted: false,
          ),
          Todo(
            id: '2',
            title: 'Buy groceries',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            remindMe: false,
            isCompleted: false,
          ),
          Todo(
            id: '3',
            title: 'Attend team meeting',
            dueDate: DateTime.now().add(const Duration(hours: 3)),
            remindMe: true,
            isCompleted: true,
          ),
        ];

  List<Todo> getTodos() {
    return _todos;
  }

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

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void addTodoAtBeginning(Todo todo) {
    _todos.insert(0, todo);
  }

  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void completeTodo(String id) {
    final todo = _todos.firstWhere((todo) => todo.id == id);
    todo.isCompleted = true;
    notifyListeners();
  }

  void updateTodoStatus(String id, bool isCompleted) {
    final todo = _todos.firstWhere((todo) => todo.id == id);
  }
}
