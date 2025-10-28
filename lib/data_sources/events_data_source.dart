import '../models/countdown_event.dart';

/// Abstract data source interface for countdown events
///
/// This abstraction allows the app to switch between local storage
/// (Hive) and remote backend (API) seamlessly in the future.
abstract class EventsDataSource {
  /// Get all countdown events
  Future<List<CountdownEvent>> getAllEvents();

  /// Get a single event by ID
  Future<CountdownEvent?> getEvent(String id);

  /// Save or update an event
  Future<void> saveEvent(CountdownEvent event);

  /// Delete an event by ID
  Future<void> deleteEvent(String id);

  /// Clear all events (useful for logout/cache clearing)
  Future<void> clearAll();
}
