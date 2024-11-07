import 'repeat_frequency.dart'; // Import the RepeatFrequency enum

class Todo {
  final String id;
  final String title;
  final DateTime? dueDate; 
  final bool remindMe; 
  final RepeatFrequency repeat; 
  bool isCompleted; 

  Todo({
    required this.id,
    required this.title,
    this.dueDate,
    this.remindMe = false, 
    this.repeat = RepeatFrequency.none, 
    this.isCompleted = false, 
  });
}
