import 'package:get/get.dart';
import '../app/app_logger.dart';
import '../models/countdown_event.dart';
import '../services/storage_service.dart';
import 'sharing_repo.dart';

class EventsRepo {
  final StorageService _storage = Get.find<StorageService>();
  final SharingRepo _sharingRepo = SharingRepo();

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

      // Save to local storage first
      await _storage.saveEvent(event);

      // If event is shared, update the Appwrite document automatically
      if (event.shareSlug != null && event.shareSlug!.isNotEmpty) {
        AppLogger.info('Event is shared, updating server data');
        try {
          await _sharingRepo.updateSharedEvent(event);
        } catch (e) {
          AppLogger.error('Failed to update shared event on server', e);
          // Don't fail the save if server update fails - local is more important
        }
      }

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save event', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      AppLogger.info('Deleting event: $id');

      // Get the event first to check if it's shared
      final event = await getEvent(id);

      // If event is shared, delete from server first
      if (event != null && event.shareSlug != null && event.deletionToken != null) {
        AppLogger.info('Event is shared, deleting from server first');
        await _sharingRepo.deleteSharedEvent(
          event.shareSlug!,
          event.deletionToken!,
        );
      }

      // Delete from local storage
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
