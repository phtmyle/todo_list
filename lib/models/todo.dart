import 'package:flutter/material.dart';
import 'package:todo_list/models/repeat_frequency.dart';

class Todo {
  final String id;
  final String title;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final RepeatFrequency repeat;
  bool isCompleted;
  bool isImportant; //

  Todo({
    required this.id,
    required this.title,
    this.dueDate,
    this.dueTime,
    this.repeat = RepeatFrequency.none,
    this.isCompleted = false,
    this.isImportant = false, // Initialize it
  });
}
