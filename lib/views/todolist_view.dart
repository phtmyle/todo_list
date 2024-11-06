import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/viewmodels/todolist_viewmodel.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key, required this.title});

  final String title;

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _addTodo() {
    if (_titleController.text.isNotEmpty) {
      Provider.of<TodolistViewModel>(context, listen: false)
          .addTodo(_titleController.text, _selectedDate);
      _titleController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Todo Title'),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: const Text('Select Due Date'),
            ),
            ElevatedButton(
              onPressed: _addTodo,
              child: const Text('Add Todo'),
            ),
            Consumer<TodolistViewModel>(
              builder: (context, viewModel, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = viewModel.todos[index];
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.dueDate.toString()),
                        trailing: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (bool? value) {
                            viewModel.markAsCompleted(todo.id);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
