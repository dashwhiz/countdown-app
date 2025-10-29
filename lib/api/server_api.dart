import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class ServerAPI {
  static final ServerAPI _instance = ServerAPI._internal();
  factory ServerAPI() => _instance;

  late final Client _client;
  late final Databases _databases;

  String get _endpoint => 'https://cloud.appwrite.io/v1';
  String get _projectId => 'YOUR_PROJECT_ID';
  String get _databaseId => 'YOUR_DATABASE_ID';
  String get _sharedEventsCollection => 'shared_events';
  String get _reactionsCollection => 'reactions';

  ServerAPI._internal() {
    _client = Client()
      ..setEndpoint(_endpoint)
      ..setProject(_projectId);
    _databases = Databases(_client);
  }

  Future<Document> createSharedEvent({
    required String slug,
    required String title,
    required String targetDate,
    required String timezone,
    required String emoji,
    required int colorValue,
    String? themeId,
    String? vanitySlug,
    bool isPro = false,
  }) async {
    return await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _sharedEventsCollection,
      documentId: slug,
      data: {
        'slug': slug,
        'title': title,
        'targetDate': targetDate,
        'timezone': timezone,
        'emoji': emoji,
        'colorValue': colorValue,
        'themeId': themeId,
        'vanitySlug': vanitySlug,
        'isPro': isPro,
        'reactionCount': 0,
      },
    );
  }

  Future<Document> getSharedEvent(String slug) async {
    return await _databases.getDocument(
      databaseId: _databaseId,
      collectionId: _sharedEventsCollection,
      documentId: slug,
    );
  }

  Future<DocumentList> getReactions(String eventSlug) async {
    return await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _reactionsCollection,
      queries: [
        Query.equal('eventSlug', eventSlug),
      ],
    );
  }

  Future<Document> addReaction({
    required String eventSlug,
    required String ipHash,
  }) async {
    return await _databases.createDocument(
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
