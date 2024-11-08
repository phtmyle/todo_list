enum RepeatFrequency {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

extension RepeatFrequencyExtension on RepeatFrequency {
  String get displayName {
    switch (this) {
      case RepeatFrequency.none:
        return 'No Repeat';
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
      case RepeatFrequency.yearly:
        return 'Yearly';
      default:
        return '';
    }
  }
}
