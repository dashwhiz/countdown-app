import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../api/server_api.dart';
import '../app/app_logger.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../services/storage_service.dart';

class SharingRepo {
  final ServerAPI _api = ServerAPI();
  final StorageService _storage = Get.find<StorageService>();

  Future<String?> shareEvent(CountdownEvent event) async {
    try {
      if (event.shareSlug != null) {
        AppLogger.info('Event already shared: ${event.shareSlug}');
        return '${AppStrings.shareUrlBase}/?id=${event.shareSlug}';
      }

      final slug = const Uuid().v4().substring(0, 8);
      AppLogger.info('Creating share for event: ${event.title} (slug: $slug)');

      await _api.createSharedEvent(
        slug: slug,
        title: event.title,
        targetDate: event.targetDate.toIso8601String(),
        timezone: event.timezone,
        emoji: event.emoji,
        colorValue: event.colorValue,
        themeId: event.themeId,
        vanitySlug: event.vanitySlug,
      );

      final updatedEvent = event.copyWith(shareSlug: slug);
      await _storage.saveEvent(updatedEvent);

      return '${AppStrings.shareUrlBase}/?id=$slug';
    } catch (e, stackTrace) {
      AppLogger.error('Failed to share event', e, stackTrace);
      return null;
    }
  }

  Future<CountdownEvent?> getSharedEvent(String slug) async {
    try {
      AppLogger.debug('Fetching shared event: $slug');
      final doc = await _api.getSharedEvent(slug);

      return CountdownEvent.fromJson({
        'id': doc.data['slug'],
        'title': doc.data['title'],
        'targetDate': doc.data['targetDate'],
        'timezone': doc.data['timezone'],
        'colorValue': doc.data['colorValue'],
        'emoji': doc.data['emoji'],
        'isPinned': false,
        'shareSlug': doc.data['slug'],
        'vanitySlug': doc.data['vanitySlug'],
        'themeId': doc.data['themeId'],
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      AppLogger.warning('Failed to get shared event: $slug', e, stackTrace);
      return null;
    }
  }

  Future<int> getReactionCount(String eventSlug) async {
    try {
      AppLogger.debug('Getting reaction count for: $eventSlug');
      final result = await _api.getReactions(eventSlug);
      return result.total;
    } catch (e, stackTrace) {
      AppLogger.warning('Failed to get reaction count', e, stackTrace);
      return 0;
    }
  }

  Future<bool> addReaction(String eventSlug, String ipHash) async {
    try {
      AppLogger.info('Adding reaction for event: $eventSlug');
      await _api.addReaction(eventSlug: eventSlug, ipHash: ipHash);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add reaction', e, stackTrace);
      return false;
    }
  }
}
