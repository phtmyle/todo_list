import 'package:flutter/material.dart';
import 'package:todo_list/extensions/string_extensions.dart';
import 'package:todo_list/services/notification_service.dart';

import '../models/repeat_frequency.dart';
import '../models/todo.dart';
import '../viewmodels/todolist_viewmodel.dart';

class TodoListView extends StatefulWidget {
  final TodoListViewModel viewModel;

  const TodoListView({super.key, required this.viewModel});

  @override
  TodoListViewState createState() => TodoListViewState();
}

class TodoListViewState extends State<TodoListView> {
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();
  final NotificationService notificationService = NotificationService();

  void _addTodo() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddTodoBottomSheet(
          onAdd: (title, dueDate, remindMe, repeat) {
            final newTodo = Todo(
              id: DateTime.now().toString(),
              title: title,
              dueDate: dueDate,
              remindMe: remindMe,
              repeat: repeat,
              isCompleted: false, // New task is initially not completed
            );
            widget.viewModel.addTodo(newTodo);
            if (remindMe) {
              notificationService.scheduleNotification(newTodo);
            }
            Navigator.of(context).pop();
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> pendingTodos =
        widget.viewModel.getTodos().where((todo) => !todo.isCompleted).toList();
    List<Todo> completedTodos =
        widget.viewModel.getTodos().where((todo) => todo.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Task'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Pending Tasks
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Pending Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...pendingTodos.map((todo) {
                  return ListTile(
                    title: Text(todo.title),
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            todo.isCompleted = value;
                          });
                          widget.viewModel.updateTodoStatus(todo.id, value);
                        }
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        // Logic for starring the task
                      },
                    ),
                  );
                }),
                const Divider(),
                // Completed Tasks
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Completed ${completedTodos.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...completedTodos.map((todo) {
                  return ListTile(
                    title: Text(
                      todo.title,
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough),
                    ),
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            todo.isCompleted = value;
                          });
                          widget.viewModel.updateTodoStatus(todo.id, value);
                        }
                      },
                    ),
                    trailing: const Icon(Icons.star, color: Colors.grey),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoBottomSheet extends StatefulWidget {
  final Function(String title, DateTime? dueDate, bool remindMe,
      RepeatFrequency repeat) onAdd;

  const AddTodoBottomSheet({super.key, required this.onAdd});

  @override
  _AddTodoBottomSheetState createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  String title = '';
  DateTime? dueDate;
  bool remindMe = false;
  RepeatFrequency repeat = RepeatFrequency.none;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Add a task'),
            onChanged: (value) => title = value,
          ),
          Row(
            children: [
              Text(dueDate == null
                  ? 'No date chosen!'
                  : 'Due Date: ${dueDate!.toLocal()}'.split(' ')[0]),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: remindMe,
                onChanged: (bool? value) {
                  setState(() {
                    remindMe = value ?? false;
                  });
                },
              ),
              const Icon(Icons.notifications),
              const Text(' Remind Me'),
            ],
          ),
          DropdownButton<RepeatFrequency>(
            value: repeat,
            items: RepeatFrequency.values
                .map<DropdownMenuItem<RepeatFrequency>>(
                    (RepeatFrequency value) {
              return DropdownMenuItem<RepeatFrequency>(
                value: value,
                child: Text(value.toString().split('.').last.capitalize()),
              );
            }).toList(),
            onChanged: (RepeatFrequency? newValue) {
              setState(() {
                repeat = newValue!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty) {
                widget.onAdd(title, dueDate, remindMe, repeat);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
