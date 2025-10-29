import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../app/app_constants.dart';
import '../app/app_logger.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../services/appwrite_service.dart';

/// Repository for managing shared countdown pages and reactions
class SharingRepo {
  final AppwriteService _appwrite = Get.find<AppwriteService>();

  /// Create or get existing share slug for an event
  ///
  /// Returns a map with 'slug' and 'deletionToken' that can be used to share and delete
  Future<Map<String, String>?> createOrGetShareSlug(CountdownEvent event) async {
    try {
      AppLogger.info('[SharingRepo] Creating share for event: ${event.title}');

      // If event already has a slug, return it with existing token
      if (event.shareSlug != null && event.shareSlug!.isNotEmpty) {
        AppLogger.debug('[SharingRepo] Event already has slug: ${event.shareSlug}');
        return {
          'slug': event.shareSlug!,
          'deletionToken': event.deletionToken ?? '', // Should always exist
        };
      }

      // Generate new slug and deletion token
      final slug = _generateSlug();
      final deletionToken = const Uuid().v4(); // Full UUID with dashes (36 chars)
      AppLogger.debug('[SharingRepo] Generated new slug: $slug, token: $deletionToken');

      // Create document in Appwrite
      final document = await _appwrite.databases.createDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        documentId: ID.unique(),
        data: {
          'slug': slug,
          'deletionToken': deletionToken,
          'title': event.title,
          'targetDate': event.targetDate.toUtc().toIso8601String(),
          'eventCreatedAt': event.createdAt.toUtc().toIso8601String(),
          'timezone': event.timezone,
          'emoji': event.emoji,
          'colorValue': event.colorValue,
          'reactionCount': 0,
        },
      );

      AppLogger.info('[SharingRepo] Share created successfully: $slug');
      return {
        'slug': document.data['slug'] as String,
        'deletionToken': document.data['deletionToken'] as String,
      };
    } catch (e, stackTrace) {
      AppLogger.error('[SharingRepo] Failed to create share', e, stackTrace);

      // Check for specific error types
      if (AppwriteService.isNetworkError(e)) {
        throw Exception(AppStrings.errorNetwork);
      } else if (AppwriteService.isRateLimitError(e)) {
        throw Exception(AppStrings.errorRateLimit);
      } else {
        throw Exception(AppStrings.errorCreateShareLink);
      }
    }
  }

  /// Get shared event by slug
  ///
  /// Used by web page to display the countdown
  Future<Map<String, dynamic>?> getSharedEvent(String slug) async {
    try {
      AppLogger.debug('[SharingRepo] Fetching shared event: $slug');

      // Query by slug
      final result = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        queries: [
          Query.equal('slug', slug),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) {
        AppLogger.warning('[SharingRepo] Shared event not found: $slug');
        return null;
      }

      final doc = result.documents.first;
      AppLogger.debug('[SharingRepo] Found shared event: ${doc.data['title']}');

      return {
        'id': doc.$id,
        'slug': doc.data['slug'],
        'title': doc.data['title'],
        'targetDate': DateTime.parse(doc.data['targetDate']).toLocal(),
        'eventCreatedAt': DateTime.parse(doc.data['eventCreatedAt']).toLocal(),
        'timezone': doc.data['timezone'],
        'emoji': doc.data['emoji'],
        'colorValue': doc.data['colorValue'],
        'reactionCount': doc.data['reactionCount'] ?? 0,
      };
    } catch (e, stackTrace) {
      AppLogger.error('[SharingRepo] Failed to get shared event', e, stackTrace);

      if (AppwriteService.isNotFoundError(e)) {
        return null;
      }

      rethrow;
    }
  }

  /// Add reaction to a shared event
  ///
  /// Uses IP hashing for privacy and rate limiting
  /// Returns true if reaction was added, false if rate limited
  Future<bool> addReaction(String slug, String ipAddress) async {
    try {
      AppLogger.debug('[SharingRepo] Adding reaction to: $slug');

      // Hash IP for privacy
      final ipHash = _hashIp(ipAddress);

      // Check if this IP already reacted in the last hour
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final existingReactions = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.reactionsCollectionId,
        queries: [
          Query.equal('eventSlug', slug),
          Query.equal('ipHash', ipHash),
          Query.greaterThan('timestamp', oneHourAgo.toIso8601String()),
          Query.limit(1),
        ],
      );

      if (existingReactions.documents.isNotEmpty) {
        AppLogger.warning('[SharingRepo] IP already reacted recently: $ipHash');
        return false; // Rate limited
      }

      // Add reaction document
      await _appwrite.databases.createDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.reactionsCollectionId,
        documentId: ID.unique(),
        data: {
          'eventSlug': slug,
          'ipHash': ipHash,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Increment reaction count on shared event
      await _incrementReactionCount(slug);

      AppLogger.info('[SharingRepo] Reaction added successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('[SharingRepo] Failed to add reaction', e, stackTrace);

      if (AppwriteService.isRateLimitError(e)) {
        return false; // Rate limited by Appwrite
      }

      rethrow;
    }
  }

  /// Get reaction count for a shared event
  Future<int> getReactionCount(String slug) async {
    try {
      final event = await getSharedEvent(slug);
      return event?['reactionCount'] ?? 0;
    } catch (e) {
      AppLogger.error('[SharingRepo] Failed to get reaction count', e);
      return 0;
    }
  }

  /// Delete a shared event by slug and deletion token
  ///
  /// Returns true if successful, false if not found or token invalid
  Future<bool> deleteSharedEvent(String slug, String deletionToken) async {
    try {
      AppLogger.info('[SharingRepo] Deleting shared event: $slug');

      // Find the document by slug
      final result = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        queries: [
          Query.equal('slug', slug),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) {
        AppLogger.warning('[SharingRepo] Shared event not found: $slug');
        return false;
      }

      final doc = result.documents.first;

      // Verify deletion token
      final storedToken = doc.data['deletionToken'] as String?;
      if (storedToken != deletionToken) {
        AppLogger.warning('[SharingRepo] Invalid deletion token for: $slug');
        return false;
      }

      // Delete the document
      await _appwrite.databases.deleteDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        documentId: doc.$id,
      );

      // Also delete all reactions for this event
      await _deleteReactionsForEvent(slug);

      AppLogger.info('[SharingRepo] Successfully deleted shared event: $slug');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('[SharingRepo] Failed to delete shared event', e, stackTrace);
      return false;
    }
  }

  /// Delete all shared events for given list of events
  ///
  /// Returns count of successfully deleted events
  Future<int> deleteAllSharedEvents(List<CountdownEvent> events) async {
    int deletedCount = 0;

    for (final event in events) {
      if (event.shareSlug != null && event.deletionToken != null) {
        final success = await deleteSharedEvent(
          event.shareSlug!,
          event.deletionToken!,
        );
        if (success) deletedCount++;
      }
    }

    AppLogger.info('[SharingRepo] Deleted $deletedCount shared events');
    return deletedCount;
  }

  /// Delete all reactions for an event
  Future<void> _deleteReactionsForEvent(String eventSlug) async {
    try {
      // Query all reactions for this event
      final result = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.reactionsCollectionId,
        queries: [
          Query.equal('eventSlug', eventSlug),
          Query.limit(100), // Batch delete
        ],
      );

      // Delete each reaction
      for (final doc in result.documents) {
        await _appwrite.databases.deleteDocument(
          databaseId: _appwrite.databaseId,
          collectionId: _appwrite.reactionsCollectionId,
          documentId: doc.$id,
        );
      }

      AppLogger.debug('[SharingRepo] Deleted ${result.documents.length} reactions for: $eventSlug');
    } catch (e) {
      AppLogger.error('[SharingRepo] Failed to delete reactions', e);
      // Don't throw - reactions deletion is cleanup, not critical
    }
  }

  /// Increment reaction count on shared event document
  Future<void> _incrementReactionCount(String slug) async {
    try {
      // Get current event
      final result = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        queries: [
          Query.equal('slug', slug),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) return;

      final doc = result.documents.first;
      final currentCount = doc.data['reactionCount'] ?? 0;

      // Update with incremented count
      await _appwrite.databases.updateDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        documentId: doc.$id,
        data: {
          'reactionCount': currentCount + 1,
        },
      );
    } catch (e) {
      AppLogger.error('[SharingRepo] Failed to increment reaction count', e);
      // Don't throw - reaction was already created, this is just a counter update
    }
  }

  /// Generate random URL-safe slug
  String _generateSlug() {
    const uuid = Uuid();
    final id = uuid.v4().replaceAll('-', '');
    return id.substring(0, AppConstants.slugLength);
  }

  /// Hash IP address for privacy
  ///
  /// Uses SHA256 with salt for one-way hashing
  String _hashIp(String ipAddress) {
    final bytes = utf8.encode(ipAddress + AppConstants.ipHashingSalt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
