import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../app/app_logger.dart';

/// Appwrite service for managing shareable countdown pages and reactions
///
/// This service handles all communication with Appwrite backend for:
/// - Creating shareable countdown documents
/// - Fetching shared countdowns for web pages
/// - Managing reactions (double-tap hearts)
class AppwriteService extends GetxService {
  // Appwrite configuration
  static const String _endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String _projectId = '690125ed003455928b9e';
  static const String _databaseId = 'production';
  static const String _sharedEventsCollectionId = 'shared_events';
  static const String _reactionsCollectionId = 'reactions';

  // Appwrite client and services
  late final Client _client;
  late final Databases _databases;

  // Connection state
  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  /// Initialize Appwrite client
  Future<AppwriteService> init() async {
    try {
      AppLogger.info('[AppwriteService] Initializing Appwrite client...');

      _client = Client()
          .setEndpoint(_endpoint)
          .setProject(_projectId)
          .setSelfSigned(status: false); // Production = false

      _databases = Databases(_client);

      _isInitialized.value = true;
      AppLogger.info('[AppwriteService] Appwrite initialized successfully');
      return this;
    } catch (e, stackTrace) {
      AppLogger.error('[AppwriteService] Failed to initialize', e, stackTrace);
      _isInitialized.value = false;
      rethrow;
    }
  }

  /// Get database instance (for repositories)
  Databases get databases {
    if (!_isInitialized.value) {
      throw Exception('AppwriteService not initialized. Call init() first.');
    }
    return _databases;
  }

  // Collection IDs (getters for repositories)
  String get databaseId => _databaseId;
  String get sharedEventsCollectionId => _sharedEventsCollectionId;
  String get reactionsCollectionId => _reactionsCollectionId;

  /// Test connection to Appwrite
  Future<bool> testConnection() async {
    try {
      AppLogger.debug('[AppwriteService] Testing connection...');
      // Try to list documents with limit 1 (minimal request)
      await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _sharedEventsCollectionId,
        queries: [Query.limit(1)],
      );
      AppLogger.debug('[AppwriteService] Connection test successful');
      return true;
    } catch (e) {
      AppLogger.error('[AppwriteService] Connection test failed: $e');
      return false;
    }
  }

  /// Check if error is a network issue
  static bool isNetworkError(dynamic error) {
    if (error is AppwriteException) {
      // Connection errors typically have these codes
      return error.code == null ||
          error.code == 0 ||
          error.message?.contains('network') == true ||
          error.message?.contains('connection') == true ||
          error.message?.contains('timeout') == true;
    }
    return false;
  }

  /// Check if error is a rate limit error
  static bool isRateLimitError(dynamic error) {
    if (error is AppwriteException) {
      return error.code == 429 ||
          error.message?.contains('rate limit') == true ||
          error.message?.contains('too many requests') == true;
    }
    return false;
  }

  /// Check if error is a not found error
  static bool isNotFoundError(dynamic error) {
    if (error is AppwriteException) {
      return error.code == 404 ||
          error.message?.contains('not found') == true ||
          error.message?.contains('document not found') == true;
    }
    return false;
  }

  /// Get user-friendly error message
  static String getFriendlyErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return 'Network error. Please check your internet connection.';
    } else if (isRateLimitError(error)) {
      return 'Too many requests. Please try again in a moment.';
    } else if (isNotFoundError(error)) {
      return 'Content not found.';
    } else if (error is AppwriteException) {
      return error.message ?? 'An error occurred. Please try again.';
    }
    return 'An unexpected error occurred.';
  }
}
