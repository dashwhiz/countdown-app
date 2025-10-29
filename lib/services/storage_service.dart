import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app/app_logger.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../models/user_profile.dart';

class StorageService extends GetxService {
  late Box<CountdownEvent> _eventsBox;
  late Box<UserProfile> _profileBox;

  Future<StorageService> init() async {
    try {
      AppLogger.info('Initializing Hive storage...');
      await Hive.initFlutter();

      Hive.registerAdapter(CountdownEventAdapter());
      Hive.registerAdapter(UserProfileAdapter());

      _eventsBox = await Hive.openBox<CountdownEvent>(AppStrings.hiveBoxEvents);
      _profileBox = await Hive.openBox<UserProfile>(AppStrings.hiveBoxProfile);

      AppLogger.info('Storage initialized successfully');
      return this;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize storage', e, stackTrace);
      rethrow;
    }
  }

  List<CountdownEvent> getAllEvents() {
    try {
      final events = _eventsBox.values.toList()
        ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
      AppLogger.debug('Retrieved ${events.length} events');
      return events;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get events', e, stackTrace);
      return [];
    }
  }

  CountdownEvent? getEvent(String id) {
    try {
      final event = _eventsBox.get(id);
      AppLogger.debug('Retrieved event: $id');
      return event;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get event: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> saveEvent(CountdownEvent event) async {
    try {
      await _eventsBox.put(event.id, event);
      AppLogger.info('Saved event: ${event.title}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save event: ${event.title}', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _eventsBox.delete(id);
      AppLogger.info('Deleted event: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete event: $id', e, stackTrace);
      rethrow;
    }
  }

  UserProfile getProfile() {
    try {
      final profile = _profileBox.get('profile') ?? UserProfile();
      AppLogger.debug('Retrieved user profile');
      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get profile', e, stackTrace);
      return UserProfile();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _profileBox.put('profile', profile);
      AppLogger.info('Saved user profile');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save profile', e, stackTrace);
      rethrow;
    }
  }
}
