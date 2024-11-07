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

class TodoListViewState extends State<TodoListView>
    with TickerProviderStateMixin {
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();
  final NotificationService notificationService = NotificationService();
  bool isCompletedTasksExpanded = false;
  final Map<String, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _animationControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

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

  void _toggleTodoCompletion(Todo todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;

      if (!_animationControllers.containsKey(todo.id)) {
        _animationControllers[todo.id] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        );
      }

      if (todo.isCompleted) {
        _animationControllers[todo.id]!.forward();
      } else {
        _animationControllers[todo.id]!.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> pendingTodos =
        widget.viewModel.getTodos().where((todo) => !todo.isCompleted).toList();
    List<Todo> completedTodos =
        widget.viewModel.getTodos().where((todo) => todo.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Task',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5C6BC0),
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        actions: const [
          Icon(Icons.person_add_alt, size: 28),
          SizedBox(width: 12),
          Icon(Icons.more_vert, size: 28),
          SizedBox(width: 12),
        ],
      ),
      body: Container(
        color: const Color(0xFF5C6BC0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // Pending Tasks
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pendingTodos.map((todo) {
                          return Dismissible(
                            key: Key(todo.id),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              // Toggle the completion state of the todo
                              _toggleTodoCompletion(todo);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${todo.title} moved to completed")),
                              );
                            },
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.8,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _animationControllers[todo.id] ?? AnimationController(
                                  vsync: this,
                                  duration: const Duration(milliseconds: 300),
                                )..forward(),
                                curve: Curves.easeInOut,
                              )),
                              child: RotationTransition(
                                turns: Tween<double>(
                                  begin: 0.1,
                                  end: 0.0,
                                ).animate(CurvedAnimation(
                                  parent: _animationControllers[todo.id] ?? AnimationController(
                                    vsync: this,
                                    duration: const Duration(milliseconds: 300),
                                  )..forward(),
                                  curve: Curves.easeInOut,
                                )),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: GestureDetector(
                                      onTap: () => _toggleTodoCompletion(todo),
                                      child: Icon(
                                        todo.isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: todo.isCompleted
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                                    title: Text(todo.title),
                                    trailing: const Icon(Icons.star_border,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(thickness: 1),
                    // Completed Tasks Section
                    if (completedTodos.isNotEmpty)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCompletedTasksExpanded = !isCompletedTasksExpanded;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isCompletedTasksExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: const Color(0xFF5C6BC0),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Completed ${completedTodos.length}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5C6BC0),
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (isCompletedTasksExpanded) // Show completed tasks only if expanded
                                Column(
                                  children: completedTodos.map((todo) {
                                    return ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.8,
                                        end: 1.0,
                                      ).animate(CurvedAnimation(
                                        parent: _animationControllers[todo.id] ?? AnimationController(
                                          vsync: this,
                                          duration: const Duration(milliseconds: 300),
                                        )..forward(),
                                        curve: Curves.easeInOut,
                                      )),
                                      child: RotationTransition(
                                        turns: Tween<double>(
                                          begin: 0.1,
                                          end: 0.0,
                                        ).animate(CurvedAnimation(
                                          parent: _animationControllers[todo.id] ?? AnimationController(
                                            vsync: this,
                                            duration: const Duration(milliseconds: 300),
                                          )..forward(),
                                          curve: Curves.easeInOut,
                                        )),
                                        child: Card(
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          child: ListTile(
                                            leading: const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF5C6BC0)),
                                            title: Text(
                                              todo.title,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            trailing: const Icon(
                                                Icons.star_border,
                                                color: Colors.grey),
                                            onTap: () =>
                                                _toggleTodoCompletion(todo),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.add, size: 32),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.radio_button_unchecked, size: 24, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a task',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onChanged: (value) => title = value,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, size: 24, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Set due date',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications, size: 24, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Remind me',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
              Switch(
                value: remindMe,
                onChanged: (value) {
                  setState(() {
                    remindMe = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.repeat, size: 24, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Repeat', style: TextStyle(color: Colors.black)),
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
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty) {
                widget.onAdd(title, dueDate, remindMe, repeat);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Add Task', style: TextStyle(color: Colors.white)),
                ),
          ),
        ],
      ),
    );
  }
}
