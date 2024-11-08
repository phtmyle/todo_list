import 'package:flutter/material.dart';

import 'repeat_frequency.dart';

class Todo {
  final String id;
  final String title;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final RepeatFrequency repeat;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.dueDate,
    this.dueTime,
    this.repeat = RepeatFrequency.none,
    this.isCompleted = false,
  });
}
