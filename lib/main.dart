import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/viewmodels/todolist_viewmodel.dart';
import 'package:todo_list/views/todolist_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TodoListViewModel>(
      create: (_) => TodoListViewModel([]),
      // Pass an empty list or initial list of todos
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          hintColor: Colors.amber,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.grey),
          ),
        ),
        home: Consumer<TodoListViewModel>(
          builder: (context, viewModel, child) {
            return TodoListView(viewModel: viewModel);
          },
        ),
      ),
    );
  }
}
