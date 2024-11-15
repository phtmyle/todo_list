// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import '../models/todo.dart';
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   NotificationService() {
//     _initializeNotifications();
//   }
//
//   void _initializeNotifications() async {
//     tz.initializeTimeZones(); // Initialize time zones
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   Future<void> scheduleNotification(Todo todo) async {
//     if (todo.dueDate != null) {
//       DateTime dueDate = todo.dueDate!;
//       // Schedule notification 10 minutes before the due date
//       final scheduledTime = dueDate.subtract(const Duration(minutes: 10));
//
//       // Convert DateTime to tz.TZDateTime in the local time zone
//       final tz.TZDateTime tzScheduledTime =
//           tz.TZDateTime.from(scheduledTime, tz.local);
//
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         0, // Use unique ID for multiple notifications
//         'Todo Reminder',
//         'Reminder for: ${todo.title}',
//         tzScheduledTime,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'your_channel_id',
//             'your_channel_name',
//             channelDescription:
//                 'your_channel_description',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exact,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.dateAndTime,
//       );
//     }
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/todo.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this.flutterLocalNotificationsPlugin);

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(Todo todo) async {
    if (todo.dueDate != null && todo.dueTime != null) {
      final DateTime dueDateTime = DateTime(
        todo.dueDate!.year,
        todo.dueDate!.month,
        todo.dueDate!.day,
        todo.dueTime!.hour,
        todo.dueTime!.minute,
      ).subtract(const Duration(minutes: 10));

      final tz.TZDateTime tzDueDateTime =
          tz.TZDateTime.from(dueDateTime, tz.local);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        todo.id.hashCode,
        'TODO Reminder',
        'Your TODO "${todo.title}" is due in 10 minutes.',
        tzDueDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }
}
