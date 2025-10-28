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
  /// Returns the slug that can be used in URLs like: https://yourapp.com/?id=slug
  Future<String?> createOrGetShareSlug(CountdownEvent event) async {
    try {
      AppLogger.info('[SharingRepo] Creating share for event: ${event.title}');

      // If event already has a slug, return it
      if (event.shareSlug != null && event.shareSlug!.isNotEmpty) {
        AppLogger.debug('[SharingRepo] Event already has slug: ${event.shareSlug}');
        return event.shareSlug;
      }

      // Generate new slug
      final slug = _generateSlug();
      AppLogger.debug('[SharingRepo] Generated new slug: $slug');

      // Create document in Appwrite
      final document = await _appwrite.databases.createDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.sharedEventsCollectionId,
        documentId: ID.unique(),
        data: {
          'slug': slug,
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
      return document.data['slug'] as String;
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
