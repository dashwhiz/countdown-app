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

      // If event already has a slug, verify the document exists in Appwrite
      if (event.shareSlug != null && event.shareSlug!.isNotEmpty) {
        AppLogger.debug('[SharingRepo] Event already has slug: ${event.shareSlug}, verifying...');

        // Verify document exists in Appwrite
        final existing = await getSharedEvent(event.shareSlug!);
        if (existing != null) {
          AppLogger.debug('[SharingRepo] Verified document exists in Appwrite');
          return {
            'slug': event.shareSlug!,
            'deletionToken': event.deletionToken ?? '', // Should always exist
          };
        }

        // Document was deleted from Appwrite, recreate it
        AppLogger.warning('[SharingRepo] Document missing in Appwrite, recreating...');
        // Continue to create new document below (will reuse existing slug and token)
      }

      // Generate new slug and deletion token (or reuse if document was missing)
      String slug;
      if (event.shareSlug != null) {
        // Reuse existing slug if recreating deleted document
        slug = event.shareSlug!;
      } else {
        // Generate new unique slug
        slug = await _generateUniqueSlug();
      }

      final deletionToken = event.deletionToken ?? const Uuid().v4(); // Full UUID with dashes (36 chars)
      AppLogger.debug('[SharingRepo] Using slug: $slug, token: $deletionToken');

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

  /// Update an existing shared event with new data
  ///
  /// Called automatically when editing a shared event
  Future<void> updateSharedEvent(CountdownEvent event) async {
    if (event.shareSlug == null || event.shareSlug!.isEmpty) return;

    try {
      AppLogger.info('[SharingRepo] Updating shared event: ${event.shareSlug}');

      // Find the existing document
      final result = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        queries: [
          Query.equal('slug', event.shareSlug!),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) {
        AppLogger.warning('[SharingRepo] Shared event not found: ${event.shareSlug}');
        return;
      }

      final doc = result.documents.first;

      // Update the document with new event data
      await _appwrite.databases.updateDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        documentId: doc.$id,
        data: {
          'title': event.title,
          'targetDate': event.targetDate.toUtc().toIso8601String(),
          'timezone': event.timezone,
          'emoji': event.emoji,
          'colorValue': event.colorValue,
          // Keep existing reactionCount and deletionToken
        },
      );

      AppLogger.info('[SharingRepo] Successfully updated shared event');
    } catch (e, stackTrace) {
      AppLogger.error('[SharingRepo] Failed to update shared event', e, stackTrace);
      rethrow;
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

      // Delete all reactions first (before deleting the document)
      // If reaction deletion fails, document remains intact for retry
      await _deleteReactionsForEvent(slug);

      // Delete the document
      await _appwrite.databases.deleteDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        documentId: doc.$id,
      );

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
  /// Deletes in parallel for better performance
  Future<int> deleteAllSharedEvents(List<CountdownEvent> events) async {
    final sharedEvents = events.where(
      (e) => e.shareSlug != null && e.deletionToken != null,
    ).toList();

    if (sharedEvents.isEmpty) {
      AppLogger.info('[SharingRepo] No shared events to delete');
      return 0;
    }

    AppLogger.info('[SharingRepo] Deleting ${sharedEvents.length} shared events in parallel');

    // Delete all events in parallel using Future.wait
    final results = await Future.wait(
      sharedEvents.map((event) => deleteSharedEvent(
        event.shareSlug!,
        event.deletionToken!,
      )),
    );

    // Count successes
    final deletedCount = results.where((success) => success).length;

    AppLogger.info('[SharingRepo] Deleted $deletedCount/${sharedEvents.length} shared events');
    return deletedCount;
  }

  /// Delete all reactions for an event
  Future<void> _deleteReactionsForEvent(String eventSlug) async {
    try {
      int totalDeleted = 0;
      bool hasMore = true;

      // Loop until all reactions are deleted (handles >100 reactions)
      while (hasMore) {
        // Query reactions for this event
        final result = await _appwrite.databases.listDocuments(
          databaseId: _appwrite.databaseId,
          collectionId: _appwrite.reactionsCollectionId,
          queries: [
            Query.equal('eventSlug', eventSlug),
            Query.limit(100), // Batch size
          ],
        );

        if (result.documents.isEmpty) {
          hasMore = false;
          break;
        }

        // Delete each reaction in this batch
        for (final doc in result.documents) {
          await _appwrite.databases.deleteDocument(
            databaseId: _appwrite.databaseId,
            collectionId: _appwrite.reactionsCollectionId,
            documentId: doc.$id,
          );
          totalDeleted++;
        }

        // Check if there are more reactions to delete
        hasMore = result.documents.length == 100;
      }

      AppLogger.debug('[SharingRepo] Deleted $totalDeleted reactions for: $eventSlug');
    } catch (e) {
      AppLogger.error('[SharingRepo] Failed to delete reactions', e);
      // Don't throw - reactions deletion is cleanup, not critical
    }
  }

  /// Increment reaction count on shared event document
  ///
  /// Note: Uses read-then-write pattern due to Appwrite limitations.
  /// Race condition possible with simultaneous reactions (eventual consistency).
  /// The reaction document is source of truth, this counter is for display only.
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

      if (result.documents.isEmpty) {
        AppLogger.warning('[SharingRepo] Event not found for reaction increment: $slug');
        return;
      }

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

      AppLogger.debug('[SharingRepo] Incremented reaction count for $slug to ${currentCount + 1}');
    } catch (e) {
      AppLogger.error('[SharingRepo] Failed to increment reaction count for $slug', e);
      // Don't throw - reaction was already created, this is just a counter update
      // The count may be slightly off but reactions collection is source of truth
    }
  }

  /// Generate random URL-safe slug
  String _generateSlug() {
    const uuid = Uuid();
    final id = uuid.v4().replaceAll('-', '');
    return id.substring(0, AppConstants.slugLength);
  }

  /// Generate unique slug (verified against Appwrite)
  ///
  /// Checks for collisions and regenerates if needed (extremely unlikely)
  Future<String> _generateUniqueSlug() async {
    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      final slug = _generateSlug();

      // Check if slug already exists in Appwrite
      final existing = await getSharedEvent(slug);
      if (existing == null) {
        // Slug is unique, return it
        AppLogger.debug('[SharingRepo] Generated unique slug: $slug (attempt ${attempts + 1})');
        return slug;
      }

      // Collision detected (extremely rare)
      attempts++;
      AppLogger.warning('[SharingRepo] Slug collision detected: $slug (attempt $attempts/$maxAttempts)');
    }

    // Fallback: use full UUID if all attempts fail (virtually impossible)
    final fallbackSlug = const Uuid().v4().replaceAll('-', '');
    AppLogger.error('[SharingRepo] Failed to generate unique slug after $maxAttempts attempts, using full UUID');
    return fallbackSlug;
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
