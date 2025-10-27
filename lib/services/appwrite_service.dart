import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../models/countdown_event.dart';

class AppwriteService extends GetxService {
  late Client _client;
  late Databases _databases;

  String get _endpoint => 'https://cloud.appwrite.io/v1';
  String get _projectId => 'YOUR_PROJECT_ID';
  String get _databaseId => 'YOUR_DATABASE_ID';
  String get _sharedEventsCollection => 'shared_events';
  String get _reactionsCollection => 'reactions';

  Future<AppwriteService> init() async {
    _client = Client()
      ..setEndpoint(_endpoint)
      ..setProject(_projectId);

    _databases = Databases(_client);

    return this;
  }

  Future<String> createSharedEvent(CountdownEvent event, String slug) async {
    await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _sharedEventsCollection,
      documentId: slug,
      data: {
        'slug': slug,
        'title': event.title,
        'targetDate': event.targetDate.toIso8601String(),
        'timezone': event.timezone,
        'emoji': event.emoji,
        'colorValue': event.colorValue,
        'themeId': event.themeId,
        'vanitySlug': event.vanitySlug,
        'isPro': false,
        'reactionCount': 0,
      },
    );

    return slug;
  }

  Future<CountdownEvent?> getSharedEvent(String slug) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _sharedEventsCollection,
        documentId: slug,
      );

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
    } catch (e) {
      return null;
    }
  }

  Future<int> getReactionCount(String eventSlug) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _reactionsCollection,
        queries: [
          Query.equal('eventSlug', eventSlug),
        ],
      );
      return result.total;
    } catch (e) {
      return 0;
    }
  }

  Future<void> addReaction(String eventSlug, String ipHash) async {
    await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _reactionsCollection,
      documentId: 'unique()',
      data: {
        'eventSlug': eventSlug,
        'ipHash': ipHash,
        'reactionType': 'heart',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
