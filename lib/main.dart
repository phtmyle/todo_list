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
  runApp(const MyApp());
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

        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        // Define custom colors
        extensions: const <ThemeExtension<dynamic>>[
          CustomColors(
            unsetValueColor: Colors.grey,
            setValueColor: Color(0xFF5D70BD),
          ),
        ],
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

class CustomColors extends ThemeExtension<CustomColors> {
  final Color unsetValueColor;
  final Color setValueColor;

  const CustomColors({
    required this.unsetValueColor,
    required this.setValueColor,
  });

  @override
  CustomColors copyWith({
    Color? unsetValueColor,
    Color? setValueColor,
  }) {
    return CustomColors(
      unsetValueColor: unsetValueColor ?? this.unsetValueColor,
      setValueColor: setValueColor ?? this.setValueColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      unsetValueColor: Color.lerp(unsetValueColor, other.unsetValueColor, t)!,
      setValueColor: Color.lerp(setValueColor, other.setValueColor, t)!,
    );
  }
}
