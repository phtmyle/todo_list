import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:todo_list/viewmodels/todolist_viewmodel.dart';
import 'package:todo_list/views/todolist_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationService notificationService =
      NotificationService(flutterLocalNotificationsPlugin);
  await notificationService.initialize();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TodoListViewModel>(
      create: (_) =>
          TodoListViewModel(notificationService: notificationService),
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
