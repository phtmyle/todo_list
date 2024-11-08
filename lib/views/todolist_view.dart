import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/services/notification_service.dart';

import '../main.dart';
import '../models/repeat_frequency.dart';
import '../models/todo.dart';
import '../viewmodels/todolist_viewmodel.dart';

class TodoListTile extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onToggleCompletion;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onToggleCompletion,
  });

  @override
  State<TodoListTile> createState() => _TodoListTileState();
}

class _TodoListTileState extends State<TodoListTile> {
  bool showTrashIcon = false;
  bool showDetails = false;
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: _hideAllOverlays,
          behavior: HitTestBehavior.opaque,
          child: Container(color: Colors.transparent),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideAllOverlays() {
    setState(() {
      showTrashIcon = false;
      showDetails = false;
    });
    _hideOverlay();
  }

  void _toggleTrashIcon() {
    setState(() {
      showTrashIcon = !showTrashIcon;
      if (showTrashIcon) {
        showDetails = false; // Hide details if showing trash
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  void _toggleDetails() {
    setState(() {
      showDetails = !showDetails;
      if (showDetails) {
        showTrashIcon = false; // Hide trash if showing details
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  Widget _buildDetailText(String label, String? value, bool isCompleted,
      CustomColors customColors) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: isCompleted ? customColors.unsetValueColor : Colors.black,
          fontSize: 14,
          decoration:
              isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: customColors.unsetValueColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return GestureDetector(
      onLongPress: _toggleTrashIcon, // Toggle trash icon on long press
      onTap: _toggleDetails, // Toggle details on tap
      child: Stack(
        children: [
          // Main content of the tile
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.only(right: showTrashIcon ? 48 : 0),
            child: Card(
              color: Colors.white,
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => widget.onToggleCompletion(widget.todo),
                  child: Icon(
                    widget.todo.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.todo.isCompleted
                        ? Theme.of(context).primaryColor
                        : customColors.unsetValueColor,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todo.title,
                      style: TextStyle(
                        color: widget.todo.isCompleted
                            ? customColors.unsetValueColor
                            : Colors.black,
                        decoration: widget.todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: customColors.unsetValueColor,
                      ),
                    ),
                    if (showDetails) ...[
                      _buildDetailText(
                          "Due Date",
                          widget.todo.dueDate
                              ?.toLocal()
                              .toString()
                              .split(' ')[0],
                          widget.todo.isCompleted,
                          customColors),
                      _buildDetailText(
                          "Due Time",
                          widget.todo.dueTime?.format(context),
                          widget.todo.isCompleted,
                          customColors),
                      _buildDetailText(
                          "Repeat",
                          widget.todo.repeat != RepeatFrequency.none
                              ? widget.todo.repeat.displayName
                              : null,
                          widget.todo.isCompleted,
                          customColors),
                    ],
                  ],
                ),
                trailing: widget.todo.isCompleted
                    ? null
                    : IconButton(
                        icon: Icon(
                          widget.todo.isImportant
                              ? Icons.star
                              : Icons.star_border,
                          color: widget.todo.isImportant
                              ? Colors.yellow
                              : customColors.unsetValueColor,
                        ),
                        onPressed: () {
                          Provider.of<TodoListViewModel>(context, listen: false)
                              .toggleTodoImportance(widget.todo);
                          setState(() {}); // Refresh the UI
                        },
                      ),
              ),
            ),
          ),
          // Trash icon that only appears when showTrashIcon is true
          if (showTrashIcon)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Provider.of<TodoListViewModel>(context, listen: false)
                      .removeTodo(widget.todo.id);
                  _hideAllOverlays(); // Hide trash icon after deletion
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TodoListView extends StatefulWidget {
  final TodoListViewModel viewModel;

  const TodoListView({super.key, required this.viewModel});

  @override
  TodoListViewState createState() => TodoListViewState();
}

class TodoListViewState extends State<TodoListView> {
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();
  bool isCompletedTasksExpanded = false;
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    notificationService =
        NotificationService(FlutterLocalNotificationsPlugin());
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
          onAdd: (title, dueDate, dueTime, repeat) {
            final newTodo = Todo(
              id: DateTime.now().toString(),
              title: title,
              dueDate: dueDate,
              dueTime: dueTime,
              repeat: repeat,
            );
            widget.viewModel.addTodoAtBeginning(newTodo);
            notificationService.scheduleNotification(newTodo);
            Navigator.of(context).pop();
            setState(() {});
          },
        );
      },
    );
  }

  void _toggleTodoCompletion(Todo todo) {
    setState(() {
      widget.viewModel.toggleTodoCompletion(todo);
    });
  }

  void _onSearchIconPressed() {
    showSearch(
      context: context,
      delegate: TodoSearchDelegate(widget.viewModel),
    ).then((_) {
      setState(() {}); // Refresh the UI when the search is closed
    });
  }

  List<Todo> _filterTodosByCategory(List<Todo> todos, String category) {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    List<Todo> filteredTodos;

    switch (category) {
      case 'Today':
        filteredTodos = todos
            .where((todo) =>
                todo.dueDate != null &&
                todo.dueDate!.year == now.year &&
                todo.dueDate!.month == now.month &&
                todo.dueDate!.day == now.day)
            .toList();
        break;
      case 'Tomorrow':
        filteredTodos = todos
            .where((todo) =>
                todo.dueDate != null &&
                todo.dueDate!.year == tomorrow.year &&
                todo.dueDate!.month == tomorrow.month &&
                todo.dueDate!.day == tomorrow.day)
            .toList();
        break;
      case 'Upcoming':
        filteredTodos = todos
            .where((todo) => todo.dueDate == null || todo.dueDate!.isAfter(now))
            .toList();
        break;
      default: // 'All'
        filteredTodos = todos;
    }

    filteredTodos.sort((a, b) {
      if (a.isImportant && !b.isImportant) return -1;
      if (!a.isImportant && b.isImportant) return 1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });

    return filteredTodos;
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> todos = widget.viewModel.getTodos();
    List<Todo> filteredTodos = _filterTodosByCategory(todos, selectedCategory);
    List<Todo> pendingTodos =
        filteredTodos.where((todo) => !todo.isCompleted).toList();
    List<Todo> completedTodos =
        filteredTodos.where((todo) => todo.isCompleted).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isDense: true,
                icon: const ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Icon(Icons.filter_list),
                ),
                items: <String>['All', 'Today', 'Upcoming'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return <String>['All', 'Today', 'Upcoming']
                      .map<Widget>((String item) {
                    return Text(item);
                  }).toList();
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _onSearchIconPressed,
            ),
            const Icon(Icons.more_vert, size: 28),
            const SizedBox(width: 12),
          ],
        ),
        body: Container(
          color: Theme.of(context).primaryColor,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pendingTodos
                            .map((todo) => _buildDismissibleTodoItem(todo))
                            .toList(),
                      ),
                    ),
                    if (completedTodos.isNotEmpty) ...[
                      if (pendingTodos.isNotEmpty) const Divider(thickness: 1),
                      _buildCompletedTasksSection(completedTodos),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: _addTodo,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.add,
                size: 32, color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleTodoItem(Todo todo) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        _toggleTodoCompletion(todo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${todo.title} completed")),
        );
      },
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft, // Align to left for visibility
        child: const Padding(
          padding: EdgeInsets.only(left: 20.0), // Place padding on left
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Complete', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight, // Align to right for visibility
        child: const Padding(
          padding: EdgeInsets.only(right: 20.0), // Place padding on right
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Delete', style: TextStyle(color: Colors.white)),
              SizedBox(width: 8),
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: TodoListTile(
          key: ValueKey(todo.isCompleted),
          todo: todo,
          onToggleCompletion: _toggleTodoCompletion,
        ),
      ),
    );
  }

  Widget _buildCompletedTasksSection(List<Todo> completedTodos) {
    return AnimatedSize(
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
                  Icon(isCompletedTasksExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                  const SizedBox(width: 8),
                  Text(
                    'Completed ${completedTodos.length}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (isCompletedTasksExpanded)
              Column(
                children: completedTodos.map((todo) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: TodoListTile(
                      key: ValueKey(todo.isCompleted),
                      todo: todo,
                      onToggleCompletion: _toggleTodoCompletion,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class TodoSearchDelegate extends SearchDelegate<Todo?> {
  final TodoListViewModel viewModel;

  TodoSearchDelegate(this.viewModel);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Color(0xFF424242)), // Dark grey icon color
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF424242)),
      // Dark grey icon color
      textTheme: theme.textTheme.copyWith(
        headlineSmall: const TextStyle(color: Colors.black),
        bodyLarge: const TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  TextStyle? get searchFieldStyle => const TextStyle(color: Colors.black);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = viewModel.getTodos().where((todo) {
      return todo.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final todo = results[index];
            return TodoListTile(
              todo: todo,
              onToggleCompletion: (todo) {
                viewModel.toggleTodoCompletion(todo);
                close(context, todo);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = viewModel.getTodos().where((todo) {
      return todo.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final todo = suggestions[index];
            return TodoListTile(
              todo: todo,
              onToggleCompletion: (todo) {
                viewModel.toggleTodoCompletion(todo);
                showResults(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class AddTodoBottomSheet extends StatefulWidget {
  final Function(String title, DateTime? dueDate, TimeOfDay? dueTime,
      RepeatFrequency repeat) onAdd;

  const AddTodoBottomSheet({super.key, required this.onAdd});

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  String title = '';
  DateTime? dueDate;
  TimeOfDay? dueTime;
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
                        widget.onAdd(title, dueDate, dueTime, repeat);
                      }
                    },
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: title.isEmpty
                            ? Colors.grey[200]
                            : Theme.of(context).colorScheme.primary,
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
                      setState(() {
                        repeat = selectedOption ?? RepeatFrequency.none;
                      });
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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Expanded(
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            color: customColors.unsetValueColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Add a task',
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
          color: dueDate != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
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
  final TimeOfDay? dueTime;
  final ValueChanged<TimeOfDay?> onTimeChanged;

  const _SetTimeControl({
    required this.dueTime,
    required this.onTimeChanged,
  });

  @override
  _SetTimeControlState createState() => _SetTimeControlState();
}

class _SetTimeControlState extends State<_SetTimeControl> {
  TimeOfDay? dueTime;

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
          color: dueTime != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
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
                  ? 'Due at ${dueTime!.format(context)}'
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
      initialTime: dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        dueTime = picked;
      });
      widget.onTimeChanged(dueTime);
    }
  }
}

// Repeat Control Widget
class RepeatControl extends StatefulWidget {
  final ValueChanged<RepeatFrequency?> onRepeatOptionChanged;

  const RepeatControl({super.key, required this.onRepeatOptionChanged});

  @override
  State<RepeatControl> createState() => _RepeatControlState();
}

class _RepeatControlState extends State<RepeatControl> {
  RepeatFrequency? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: _selectedOption != null
              ? Theme.of(context).colorScheme.primary
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
                _selectedOption?.displayName ?? 'Repeat',
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

    showMenu<RepeatFrequency>(
      context: context,
      position: RelativeRect.fromLTRB(x, y, 0, 0),
      items: [
        _buildPopupMenuItem(RepeatFrequency.daily),
        _buildPopupMenuItem(RepeatFrequency.weekly),
        _buildPopupMenuItem(RepeatFrequency.monthly),
        _buildPopupMenuItem(RepeatFrequency.yearly),
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

  PopupMenuItem<RepeatFrequency> _buildPopupMenuItem(RepeatFrequency option) {
    return PopupMenuItem<RepeatFrequency>(
      value: option,
      child: Row(
        children: [
          getIconForRepeat(option),
          const SizedBox(width: 8),
          Text(option.displayName),
        ],
      ),
    );
  }

  // Method to get the icon for each repeat type
  Widget getIconForRepeat(RepeatFrequency option) {
    switch (option) {
      case RepeatFrequency.daily:
        return const Icon(Icons.wb_sunny);
      case RepeatFrequency.weekly:
        return const Icon(Icons.calendar_view_week);
      case RepeatFrequency.monthly:
        return const Icon(Icons.calendar_today);
      case RepeatFrequency.yearly:
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
