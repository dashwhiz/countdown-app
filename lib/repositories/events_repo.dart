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

      // If event is shared, update Appwrite first to ensure consistency
      if (event.shareSlug != null && event.shareSlug!.isNotEmpty) {
        AppLogger.info('Event is shared, updating server data first');
        try {
          await _sharingRepo.updateSharedEvent(event);
          AppLogger.info('Server update successful, saving locally');
        } catch (e) {
          AppLogger.error('Failed to update shared event on server: ${event.shareSlug}, title: "${event.title}"', e);

          // If server update fails, clear share status to prevent broken links
          // User can reshare later when connection is restored
          final unsharingEvent = CountdownEvent(
            id: event.id,
            title: event.title,
            targetDate: event.targetDate,
            timezone: event.timezone,
            colorValue: event.colorValue,
            emoji: event.emoji,
            isPinned: event.isPinned,
            shareSlug: null, // Clear share slug
            vanitySlug: event.vanitySlug,
            themeId: event.themeId,
            deletionToken: null, // Clear deletion token
            createdAt: event.createdAt,
          );

          // Save unshared version locally
          await _storage.saveEvent(unsharingEvent);
          AppLogger.warning('Cleared share status due to server sync failure');

          // Return false to indicate sync failure (triggers error listener)
          return false;
        }
      }

      // Save to local storage
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

      // Get the event first to check if it's shared
      final event = await getEvent(id);

      // If event is shared, delete from server first
      if (event != null && event.shareSlug != null && event.deletionToken != null) {
        AppLogger.info('Event is shared (slug: ${event.shareSlug}), deleting from server first');
        final serverDeleted = await _sharingRepo.deleteSharedEvent(
          event.shareSlug!,
          event.deletionToken!,
        );

        if (!serverDeleted) {
          // Server delete failed - clear share status but keep event locally
          AppLogger.error('Failed to delete from server, clearing share status: ${event.shareSlug}');

          // Clear shareSlug and deletionToken so event becomes local-only
          final unsharingEvent = CountdownEvent(
            id: event.id,
            title: event.title,
            targetDate: event.targetDate,
            timezone: event.timezone,
            colorValue: event.colorValue,
            emoji: event.emoji,
            isPinned: event.isPinned,
            shareSlug: null, // Clear share slug
            vanitySlug: event.vanitySlug,
            themeId: event.themeId,
            deletionToken: null, // Clear deletion token
            createdAt: event.createdAt,
          );

          await _storage.saveEvent(unsharingEvent);
          return false; // Indicate failure (server data may remain)
        }

        AppLogger.info('Server delete successful');
      }

      // Delete from local storage
      await _storage.deleteEvent(id);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete event: $id', e, stackTrace);
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
