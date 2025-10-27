import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/countdown_event.dart';
import '../models/user_profile.dart';

class StorageService extends GetxService {
  late Box<CountdownEvent> _eventsBox;
  late Box<UserProfile> _profileBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CountdownEventAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    _eventsBox = await Hive.openBox<CountdownEvent>('events');
    _profileBox = await Hive.openBox<UserProfile>('profile');

    return this;
  }

  List<CountdownEvent> getAllEvents() {
    return _eventsBox.values.toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  CountdownEvent? getEvent(String id) {
    return _eventsBox.get(id);
  }

  Future<void> saveEvent(CountdownEvent event) async {
    await _eventsBox.put(event.id, event);
  }

  Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
  }

  UserProfile getProfile() {
    return _profileBox.get('profile') ?? UserProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.put('profile', profile);
  }
}
