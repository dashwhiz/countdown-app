import '../models/countdown_event.dart';
import '../utils/date_utils.dart';

/// View model for displaying a CountdownEvent in the UI
/// Contains only UI formatting logic - no business logic or state management
class EventViewModel {
  EventViewModel(this.model);

  final CountdownEvent model;

  // Formatted UI strings
  String get formattedDate => DateUtils.formatDateTime(model.targetDate);

  String get formattedTimeRemaining {
    if (model.hasEnded) {
      return 'Event ended';
    }
    return DateUtils.formatTimeRemaining(model.timeRemaining);
  }
}
