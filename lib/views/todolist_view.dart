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
    );
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
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _TaskTitleField(
                  onChanged: (value) {
                    setState(() {
                      title = value; // Update title
                    });
                  },
                ),
                const SizedBox(width: 8),
                // Floating Action Button
                GestureDetector(
                  onTap: () {
                    if (title.isNotEmpty) {
                      widget.onAdd(title, dueDate, remindMe, repeat);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: title.isEmpty
                          ? const Color(0xFFC2C2C2)
                          : const Color(0xFF2665EE), // Color based on input
                    ),
                    child: const Icon(Icons.arrow_upward,
                        color: Colors.white), // Up arrow icon
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Scrollable Row for Controls
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align items to the start
                children: [
                  _DueDateControl(
                    dueDate: dueDate,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(width: 16),
                  _ReminderControl(
                    remindMe: remindMe,
                    onToggle: (value) {
                      setState(() {
                        remindMe = value;
                      });
                    },
                    reminderDate: reminderDate, // Pass reminder date
                    onSelectReminder: (option) {
                      switch (option) {
                        case ReminderOption.laterToday:
                          // Set reminder for later today
                          setState(() {
                            reminderDate = DateTime.now().add(const Duration(
                                hours: 2)); // Example: 2 hours from now
                          });
                          break;
                        case ReminderOption.tomorrow:
                          // Set reminder for tomorrow
                          setState(() {
                            reminderDate = DateTime.now()
                                .add(const Duration(days: 1))
                                .copyWith(
                                    hour: 9, minute: 0); // Tomorrow at 9:00 AM
                          });
                          break;
                        case ReminderOption.nextWeek:
                          // Set reminder for next week
                          setState(() {
                            reminderDate = DateTime.now()
                                .add(const Duration(days: 7))
                                .copyWith(
                                    hour: 9, minute: 0); // Next week at 9:00 AM
                          });
                          break;
                        case ReminderOption.pickDateTime:
                          // Handle picking a date and time
                          _selectDateTime(context);
                          break;
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  RepeatControl(
                    onChanged: (selectedOption) {
                      // Handle the selected repeat option here
                      print(
                          'Selected Repeat Option: ${selectedOption?.displayText}');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to pick a date and time
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          reminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
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
class _DueDateControl extends StatelessWidget {
  final DateTime? dueDate;
  final VoidCallback onTap;

  const _DueDateControl({required this.dueDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: dueDate != null
              ? const Color(0xFF5D70BD)
              : Colors.grey[200], // Background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 24,
                color:
                    dueDate != null ? Colors.white : Colors.grey), // Icon color
            const SizedBox(width: 8),
            Text(
              dueDate != null
                  ? 'Due ${dueDate!.toLocal().toString().split(' ')[0]}' // Display date
                  : 'Add due date', // Placeholder text
              style: TextStyle(
                color:
                    dueDate != null ? Colors.white : Colors.grey, // Text color
              ),
            ),
          ],
        ),
      ),
    );
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
              color: remindMe ? Colors.white : Colors.grey, // Mimic color logic
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

// Method to build a PopupMenuItem
  PopupMenuItem<ReminderOption> _buildPopupMenuItem(ReminderOption option,
      [DateTime? date]) {
    return PopupMenuItem<ReminderOption>(
      value: option,
      child: Row(
        children: [
          getIconForReminder(option), // Use the method to get the icon
          const SizedBox(width: 8),
          Text(
            option.displayText,
            style: const TextStyle(fontWeight: FontWeight.w300), // Thin style
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
        'assets/icons/double-right-sign-circle-svgrepo-com.svg', // Update the path as necessary
        width: 24, // Set the desired width
        height: 24, // Set the desired height
      );
    case ReminderOption.pickDateTime:
      return const Icon(Icons.date_range); // Material icon
    default:
      return const SizedBox(); // Return an empty widget for default case
  }
}

// Repeat Control Widget
class RepeatControl extends StatefulWidget {
  final ValueChanged<RepeatOption?>
      onChanged; // Callback for when the option changes

  const RepeatControl({super.key, required this.onChanged}); // Constructor

  @override
  State<RepeatControl> createState() => _RepeatControlState();
}

class _RepeatControlState extends State<RepeatControl> {
  RepeatOption? _selectedOption; // State variable to hold the selected option

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
            SvgPicture.asset(
              'assets/icons/repeat_solid.svg',
              width: 24, // Match icon size
              height: 24, // Match icon size
              colorFilter: ColorFilter.mode(
                _selectedOption != null
                    ? Colors.white
                    : Colors.grey, // Mimic color logic
                BlendMode.srcIn,
              ),
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
          ],
        ),
      ),
    );
  }

  void _showRepeatOptions(BuildContext context) {
    showMenu<RepeatOption>(
      context: context,
      position: const RelativeRect.fromLTRB(
          100, 100, 0, 0), // Adjust position as needed
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
          _selectedOption = value; // Update the selected option
        });
        widget.onChanged(value); // Call the onChanged callback
      }
    });
  }

  PopupMenuItem<RepeatOption> _buildPopupMenuItem(RepeatOption option) {
    return PopupMenuItem<RepeatOption>(
      value: option,
      child: Row(
        children: [
          getIconForRepeat(option), // Use the method to get the icon
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
        return const Icon(Icons.wb_sunny); // Sun icon for Daily
      case RepeatOption.weekly:
        return const Icon(
            Icons.calendar_view_week); // Weekly view calendar icon
      case RepeatOption.monthly:
        return const Icon(Icons.calendar_today); // Calendar icon for Monthly
      case RepeatOption.yearly:
        return const Icon(Icons.event); // Event icon for Yearly
      default:
        return const SizedBox(); // Return an empty widget for default case
    }
  }
}

enum RepeatOption {
  daily,
  weekly,
  monthly,
  yearly,
}

// Extension for the RepeatOption enum
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
