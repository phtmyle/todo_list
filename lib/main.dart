// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:provider/provider.dart';
// import 'package:todo_list/services/notification_service.dart';
// import 'package:todo_list/viewmodels/todolist_viewmodel.dart';
// import 'package:todo_list/views/todolist_view.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final NotificationService notificationService =
//       NotificationService(flutterLocalNotificationsPlugin);
//   await notificationService.initialize();
//
//   runApp(MyApp(notificationService: notificationService));
// }
//
// class MyApp extends StatelessWidget {
//   final NotificationService notificationService;
//
//   const MyApp({super.key, required this.notificationService});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<TodoListViewModel>(
//       create: (_) =>
//           TodoListViewModel(notificationService: notificationService),
//       child: MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           primaryColor: Colors.indigo,
//           hintColor: Colors.amber,
//           textTheme: const TextTheme(
//             bodyLarge: TextStyle(color: Colors.black),
//             bodyMedium: TextStyle(color: Colors.grey),
//           ),
//         ),
//         home: Consumer<TodoListViewModel>(
//           builder: (context, viewModel, child) {
//             return TodoListView(viewModel: viewModel);
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:todo_list/viewmodels/todolist_viewmodel.dart';
import 'package:todo_list/views/todolist_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: IconTheme(
        data: const IconThemeData(color: Colors.white),
        child: TodoListView(
          viewModel: TodoListViewModel(
            notificationService:
                NotificationService(FlutterLocalNotificationsPlugin()),
          ),
        ),
      ),
    );
  }
}
