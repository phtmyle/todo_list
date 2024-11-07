import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper method for validating a date/time value represents a future point in
/// time where `matchDateTimeComponents` is null.
void validateDateIsInTheFuture(
  DateTime scheduledDate, // Changed to DateTime
  DateTimeComponents? matchDateTimeComponents,
) {
  if (matchDateTimeComponents != null) {
    return;
  }
  // Ensure the date is not in the past, allowing today as a valid date
  final DateTime now = DateTime.now(); // Changed to DateTime
  if (scheduledDate.isBefore(now.subtract(const Duration(seconds: 1)))) {
    throw ArgumentError.value(scheduledDate, 'scheduledDate',
        'Must be a date today or in the future');
  }
}
