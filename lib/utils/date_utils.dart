/// Date and time formatting utilities
class DateUtils {
  DateUtils._();

  /// Formats a DateTime to a readable string: "DD/MM/YYYY at HH:MM"
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formats time remaining from a duration
  static String formatTimeRemaining(Duration duration) {
    if (duration.isNegative) {
      return 'Event ended';
    }

    if (duration.inDays > 0) {
      return '${duration.inDays} days remaining';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours remaining';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes remaining';
    } else {
      return 'Less than a minute';
    }
  }
}
