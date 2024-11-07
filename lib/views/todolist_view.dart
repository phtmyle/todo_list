import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/viewmodels/todolist_viewmodel.dart';

class TodolistView extends StatefulWidget {
  const TodolistView({super.key});

  @override
  State<TodolistView> createState() => _TodolistViewState();
}

class _TodolistViewState extends State<TodolistView> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selection buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['All', 'Today', 'Tomorrow', 'Upcoming'].map((category) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Text(category),
              );
            }).toList(),
          ),
          // List of todos
          Expanded(
            child: Consumer<TodoViewModel>(
              builder: (context, viewmodel, child) {
                final todos = viewmodel.getTodoByCategory(_selectedCategory);
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.dueDate.toString()),
                      trailing: IconButton(
                        onPressed: () {
                          viewmodel.markAsCompleted(todo.id);
                        },
                        icon: const Icon(Icons.check),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDate; // Changed to DateTime

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Enter todo title'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    // Set the time to midnight (00:00) to avoid timezone issues
                    selectedDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                    );
                  }
                },
                child: const Text('Select Due Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  Provider.of<TodoViewModel>(context, listen: false).addTodo(
                      titleController.text,
                      selectedDate!); // Changed to DateTime
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
