import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
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
  bool isCompletedTasksExpanded = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _addTodo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            widget.viewModel.addTodoAtBeginning(newTodo);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> pendingTodos =
        widget.viewModel.getTodos().where((todo) => !todo.isCompleted).toList();
    List<Todo> completedTodos =
        widget.viewModel.getTodos().where((todo) => todo.isCompleted).toList();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Todo List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5C6BC0),
        elevation: 0,
        actions: const [
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
                              _toggleTodoCompletion(todo);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "${todo.title} moved to completed")),
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
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              child: Card(
                                key: ValueKey(todo.isCompleted),
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
                                    isCompletedTasksExpanded =
                                        !isCompletedTasksExpanded;
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
                              if (isCompletedTasksExpanded)
                                Column(
                                  children: completedTodos.map((todo) {
                                    return AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return FadeTransition(
                                            opacity: animation, child: child);
                                      },
                                      child: Card(
                                        key: ValueKey(todo.isCompleted),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
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
    ));
  }
}

class AddTodoBottomSheet extends StatefulWidget {
  final Function(String title, DateTime? dueDate, bool remindMe,
      RepeatFrequency repeat) onAdd;

  const AddTodoBottomSheet({super.key, required this.onAdd});

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  String title = '';
  DateTime? dueDate;
  bool remindMe = false;
  DateTime? reminderDate;
  DateTime? dueTime;
  RepeatFrequency repeat = RepeatFrequency.none;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
                _TaskTitleField(
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                    onTap: () {
                      if (title.isNotEmpty) {
                        widget.onAdd(title, dueDate, remindMe, repeat);
                      }
                    },
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: title.isEmpty
                            ? const Color(0xFFC2C2C2)
                            : const Color(0xFF2665EE), // Color based on input
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white, // Icon color
                          size: 20.0,
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DueDateControl(
                    dueDate: dueDate,
                    onDateChanged: (date) {
                      setState(() {
                        dueDate = date;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // _ReminderControl(
                  //   remindMe: remindMe,
                  //   onToggle: (value) {
                  //     setState(() {
                  //       remindMe = value;
                  //     });
                  //   },
                  //   reminderDate: reminderDate,
                  //   onSelectReminder: (option) {
                  //     switch (option) {
                  //       case ReminderOption.laterToday:
                  //         setState(() {
                  //           reminderDate =
                  //               DateTime.now().add(const Duration(hours: 1));
                  //         });
                  //         break;
                  //       case ReminderOption.tomorrow:
                  //         setState(() {
                  //           reminderDate =
                  //               DateTime.now().add(const Duration(days: 1));
                  //         });
                  //         break;
                  //       case ReminderOption.nextWeek:
                  //         setState(() {
                  //           reminderDate =
                  //               DateTime.now().add(const Duration(days: 7));
                  //         });
                  //         break;
                  //       case ReminderOption.pickDateTime:
                  //         _selectDateTime(context);
                  //         break;
                  //     }
                  //   },
                  // ),
                  _SetTimeControl(
                    dueTime: dueTime,
                    onTimeChanged: (time) {
                      setState(() {
                        dueTime = time;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  RepeatControl(
                    onRepeatOptionChanged: (selectedOption) {
                      print(
                          'Selected Repeat Option: ${selectedOption?.displayText}');
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Task Title Field Widget
class _TaskTitleField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _TaskTitleField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          // Circular Icon
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.circle_outlined, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a task',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[300]),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Due Date Control Widget
class _DueDateControl extends StatefulWidget {
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onDateChanged;

  const _DueDateControl({
    required this.dueDate,
    required this.onDateChanged,
  });

  @override
  _DueDateControlState createState() => _DueDateControlState();
}

class _DueDateControlState extends State<_DueDateControl> {
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    dueDate = widget.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: dueDate != null ? const Color(0xFF5D70BD) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 24,
              color: dueDate != null ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              dueDate != null
                  ? 'Date ${dueDate!.toLocal().toString().split(' ')[0]}'
                  : 'Add due date',
              style: TextStyle(
                color: dueDate != null ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            if (dueDate != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    dueDate = null;
                  });
                  widget.onDateChanged(null);
                },
                child: const Icon(
                  CupertinoIcons.clear_circled,
                  size: 20,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

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
      widget.onDateChanged(dueDate);
    }
  }
}

// Set Time Control
class _SetTimeControl extends StatefulWidget {
  final DateTime? dueTime;
  final ValueChanged<DateTime?> onTimeChanged;

  const _SetTimeControl({
    required this.dueTime,
    required this.onTimeChanged,
  });

  @override
  _SetTimeControlState createState() => _SetTimeControlState();
}

class _SetTimeControlState extends State<_SetTimeControl> {
  DateTime? dueTime;

  @override
  void initState() {
    super.initState();
    dueTime = widget.dueTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: dueTime != null ? const Color(0xFF5D70BD) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 24,
              color: dueTime != null ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              dueTime != null
                  ? 'Due at ${DateFormat('h:mm a').format(dueTime!)}'
                  : 'Set a time',
              style: TextStyle(
                color: dueTime != null ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            if (dueTime != null)
              GestureDetector(
                  onTap: () {
                    setState(() {
                      dueTime = null;
                    });
                    widget.onTimeChanged(null);
                  },
                  child: const Icon(
                    CupertinoIcons.clear_circled,
                    size: 20,
                    color: Colors.white,
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dueTime ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        dueTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          picked.hour,
          picked.minute,
        );
      });
      widget.onTimeChanged(dueTime);
    }
  }
}

// Reminder Control Widget
class _ReminderControl extends StatelessWidget {
  final bool remindMe;
  final DateTime? reminderDate;
  final ValueChanged<bool> onToggle;
  final ValueChanged<ReminderOption> onSelectReminder;

  const _ReminderControl({
    required this.remindMe,
    required this.reminderDate,
    required this.onToggle,
    required this.onSelectReminder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!remindMe),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: remindMe ? const Color(0xFF5D70BD) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications,
              size: 24,
              color: remindMe ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _showPopupMenu(context);
              },
              child: Text(
                remindMe
                    ? 'Remind me at ${reminderDate?.toLocal().toString().split(' ')[0]}'
                    : 'Remind me',
                style: TextStyle(
                  color: remindMe ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    double x = offset.dx;
    double y = offset.dy + renderBox.size.height; // Position below the widget

    // Get the current date
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateTime nextWeek = now.add(const Duration(days: 7));

    // Show the menu
    showMenu<ReminderOption>(
      context: context,
      position: RelativeRect.fromLTRB(x, y, 0, 0),
      items: [
        _buildPopupMenuItem(ReminderOption.laterToday),
        _buildPopupMenuItem(ReminderOption.tomorrow, tomorrow),
        _buildPopupMenuItem(ReminderOption.nextWeek, nextWeek),
        const PopupMenuDivider(),
        _buildPopupMenuItem(ReminderOption.pickDateTime),
      ],
      color: Colors.white,
    ).then((value) {
      if (value != null) {
        onSelectReminder(value);
      }
    });
  }

  PopupMenuItem<ReminderOption> _buildPopupMenuItem(ReminderOption option,
      [DateTime? date]) {
    return PopupMenuItem<ReminderOption>(
      value: option,
      child: Row(
        children: [
          getIconForReminder(option),
          const SizedBox(width: 8),
          Text(
            option.displayText,
          ),
          if (date != null) ...[
            const Spacer(),
            Text(
              DateFormat('EEE, h:mm a').format(date),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

enum ReminderOption {
  laterToday,
  tomorrow,
  nextWeek,
  pickDateTime,
}

extension ReminderOptionExtension on ReminderOption {
  String get displayText {
    switch (this) {
      case ReminderOption.laterToday:
        return 'Later today';
      case ReminderOption.tomorrow:
        return 'Tomorrow';
      case ReminderOption.nextWeek:
        return 'Next week';
      case ReminderOption.pickDateTime:
        return 'Pick a date & time';
    }
  }
}

Widget getIconForReminder(ReminderOption option) {
  switch (option) {
    case ReminderOption.laterToday:
      return const Icon(Icons.update); // Material icon
    case ReminderOption.tomorrow:
      return const Icon(Icons.arrow_circle_right_outlined); // Material icon
    case ReminderOption.nextWeek:
      return SvgPicture.asset(
        'assets/icons/double-right-sign-circle-svgrepo-com.svg',
        width: 24,
        height: 24,
      );
    case ReminderOption.pickDateTime:
      return const Icon(Icons.date_range); // Material icon
    default:
      return const SizedBox();
  }
}

// Repeat Control Widget
class RepeatControl extends StatefulWidget {
  final ValueChanged<RepeatOption?> onRepeatOptionChanged;

  const RepeatControl({super.key, required this.onRepeatOptionChanged});

  @override
  State<RepeatControl> createState() => _RepeatControlState();
}

class _RepeatControlState extends State<RepeatControl> {
  RepeatOption? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: _selectedOption != null
              ? const Color(0xFF5D70BD)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.autorenew,
              size: 24,
              color: _selectedOption != null ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _showRepeatOptions(context);
              },
              child: Text(
                _selectedOption?.displayText ?? 'Repeat',
                style: TextStyle(
                  color: _selectedOption != null ? Colors.white : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedOption != null)
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOption = null;
                    });
                    widget.onRepeatOptionChanged(null);
                  },
                  child: const Icon(
                    CupertinoIcons.clear_circled,
                    size: 20,
                    color: Colors.white,
                  )),
          ],
        ),
      ),
    );
  }

  void _showRepeatOptions(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    double x = offset.dx;
    double y = offset.dy + renderBox.size.height;

    showMenu<RepeatOption>(
      context: context,
      position: RelativeRect.fromLTRB(x, y, 0, 0),
      items: [
        _buildPopupMenuItem(RepeatOption.daily),
        _buildPopupMenuItem(RepeatOption.weekly),
        _buildPopupMenuItem(RepeatOption.monthly),
        _buildPopupMenuItem(RepeatOption.yearly),
      ],
      color: Colors.white,
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedOption = value;
        });
        widget.onRepeatOptionChanged(value);
      }
    });
  }

  PopupMenuItem<RepeatOption> _buildPopupMenuItem(RepeatOption option) {
    return PopupMenuItem<RepeatOption>(
      value: option,
      child: Row(
        children: [
          getIconForRepeat(option),
          const SizedBox(width: 8),
          Text(option.displayText),
        ],
      ),
    );
  }

  // Method to get the icon for each repeat option
  Widget getIconForRepeat(RepeatOption option) {
    switch (option) {
      case RepeatOption.daily:
        return const Icon(Icons.wb_sunny);
      case RepeatOption.weekly:
        return const Icon(Icons.calendar_view_week);
      case RepeatOption.monthly:
        return const Icon(Icons.calendar_today);
      case RepeatOption.yearly:
        return const Icon(Icons.event);
      default:
        return const SizedBox();
    }
  }
}

enum RepeatOption {
  daily,
  weekly,
  monthly,
  yearly,
}

extension RepeatOptionExtension on RepeatOption {
  String get displayText {
    switch (this) {
      case RepeatOption.daily:
        return 'Daily';
      case RepeatOption.weekly:
        return 'Weekly';
      case RepeatOption.monthly:
        return 'Monthly';
      case RepeatOption.yearly:
        return 'Yearly';
    }
  }
}
