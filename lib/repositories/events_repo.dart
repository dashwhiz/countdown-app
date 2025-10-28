import '../app/app_logger.dart';
import '../data_sources/events_data_source.dart';
import '../data_sources/events_local_data_source.dart';
import '../models/countdown_event.dart';

/// Repository for managing countdown events
///
/// Uses data source abstraction to support both local and remote storage.
/// Currently configured to use local storage (Hive).
/// To switch to remote API in the future, simply inject EventsRemoteDataSource.
class EventsRepo {
  // Use local data source by default
  // TODO: In Phase 2, inject this via dependency injection based on auth state
  final EventsDataSource _dataSource = EventsLocalDataSource();

  Future<List<CountdownEvent>> getAllEvents() async {
    try {
      AppLogger.debug('[EventsRepo] Getting all events');
      return await _dataSource.getAllEvents();
    } catch (e, stackTrace) {
      AppLogger.error('[EventsRepo] Failed to get events', e, stackTrace);
      return [];
    }
  }

  Future<CountdownEvent?> getEvent(String id) async {
    try {
      AppLogger.debug('[EventsRepo] Getting event: $id');
      return await _dataSource.getEvent(id);
    } catch (e, stackTrace) {
      AppLogger.error('[EventsRepo] Failed to get event: $id', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveEvent(CountdownEvent event) async {
    try {
      AppLogger.info('[EventsRepo] Saving event: ${event.title}');
      await _dataSource.saveEvent(event);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('[EventsRepo] Failed to save event', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      AppLogger.info('[EventsRepo] Deleting event: $id');
      await _dataSource.deleteEvent(id);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('[EventsRepo] Failed to delete event', e, stackTrace);
      return false;
    }
  }

  Future<bool> clearAllEvents() async {
    try {
      AppLogger.info('[EventsRepo] Clearing all events');
      await _dataSource.clearAll();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('[EventsRepo] Failed to clear all events', e, stackTrace);
      return false;
    }
  }

  Future<bool> togglePin(String id) async {
    try {
      final event = await getEvent(id);
      if (event == null) return false;

      final updated = event.copyWith(isPinned: !event.isPinned);
      return await saveEvent(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle pin', e, stackTrace);
      return false;
    }
  }
}
