import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../core/app_logger.dart';
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
    try {
      AppLogger.info('Initializing Appwrite client...');
      _client = Client()
        ..setEndpoint(_endpoint)
        ..setProject(_projectId);

      _databases = Databases(_client);

      AppLogger.info('Appwrite client initialized');
      return this;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Appwrite', e, stackTrace);
      rethrow;
    }
  }

  Future<String> createSharedEvent(CountdownEvent event, String slug) async {
    try {
      AppLogger.info('Creating shared event: ${event.title} (slug: $slug)');
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

      AppLogger.info('Shared event created successfully');
      return slug;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create shared event', e, stackTrace);
      rethrow;
    }
  }

  Future<CountdownEvent?> getSharedEvent(String slug) async {
    try {
      AppLogger.debug('Fetching shared event: $slug');
      final doc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _sharedEventsCollection,
        documentId: slug,
      );

      AppLogger.info('Shared event retrieved successfully');
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
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _reactionsCollection,
        queries: [
          Query.equal('eventSlug', eventSlug),
        ],
      );
      AppLogger.debug('Reaction count: ${result.total}');
      return result.total;
    } catch (e, stackTrace) {
      AppLogger.warning('Failed to get reaction count', e, stackTrace);
      return 0;
    }
  }

  Future<void> addReaction(String eventSlug, String ipHash) async {
    try {
      AppLogger.info('Adding reaction for event: $eventSlug');
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
      AppLogger.info('Reaction added successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add reaction', e, stackTrace);
      rethrow;
    }
  }
}
