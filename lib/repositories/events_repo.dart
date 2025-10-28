import 'package:get/get.dart';
import '../app/app_logger.dart';
import '../models/countdown_event.dart';
import '../services/storage_service.dart';

class EventsRepo {
  final StorageService _storage = Get.find<StorageService>();

  Future<List<CountdownEvent>> getAllEvents() async {
    try {
      AppLogger.debug('Getting all events from storage');
      return _storage.getAllEvents();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get events', e, stackTrace);
      return [];
    }
  }

  Future<CountdownEvent?> getEvent(String id) async {
    try {
      AppLogger.debug('Getting event: $id');
      return _storage.getEvent(id);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get event: $id', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveEvent(CountdownEvent event) async {
    try {
      AppLogger.info('Saving event: ${event.title}');
      await _storage.saveEvent(event);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save event', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      AppLogger.info('Deleting event: $id');
      await _storage.deleteEvent(id);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete event', e, stackTrace);
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
