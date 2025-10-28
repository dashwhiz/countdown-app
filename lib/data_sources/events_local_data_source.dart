import 'package:get/get.dart';
import '../app/app_logger.dart';
import '../models/countdown_event.dart';
import '../services/storage_service.dart';
import 'events_data_source.dart';

/// Local data source implementation using Hive storage
class EventsLocalDataSource implements EventsDataSource {
  final StorageService _storage = Get.find<StorageService>();

  @override
  Future<List<CountdownEvent>> getAllEvents() async {
    try {
      AppLogger.debug('[LocalDataSource] Getting all events');
      return _storage.getAllEvents();
    } catch (e, stackTrace) {
      AppLogger.error('[LocalDataSource] Failed to get all events', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<CountdownEvent?> getEvent(String id) async {
    try {
      AppLogger.debug('[LocalDataSource] Getting event: $id');
      return _storage.getEvent(id);
    } catch (e, stackTrace) {
      AppLogger.error('[LocalDataSource] Failed to get event: $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveEvent(CountdownEvent event) async {
    try {
      AppLogger.debug('[LocalDataSource] Saving event: ${event.id}');
      await _storage.saveEvent(event);
    } catch (e, stackTrace) {
      AppLogger.error('[LocalDataSource] Failed to save event', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      AppLogger.debug('[LocalDataSource] Deleting event: $id');
      await _storage.deleteEvent(id);
    } catch (e, stackTrace) {
      AppLogger.error('[LocalDataSource] Failed to delete event: $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      AppLogger.debug('[LocalDataSource] Clearing all events');
      // Get all event IDs and delete them one by one
      final events = await getAllEvents();
      for (final event in events) {
        await deleteEvent(event.id);
      }
    } catch (e, stackTrace) {
      AppLogger.error('[LocalDataSource] Failed to clear all events', e, stackTrace);
      rethrow;
    }
  }
}
