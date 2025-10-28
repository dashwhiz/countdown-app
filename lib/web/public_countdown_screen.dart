import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_logger.dart';
import '../app/app_strings.dart';
import '../repositories/sharing_repo.dart';
import '../widgets/countdown_display.dart';
import '../models/countdown_event.dart';
import 'dart:async';
import 'package:web/web.dart' as web;

/// Helper class for browser localStorage operations
class WebStorageHelper {
  static const String _browserIdKey = 'countdown_browser_id';
  static const String _reactionPrefix = 'reaction_';

  /// Get or generate unique browser ID
  static String getBrowserId() {
    final storage = web.window.localStorage;
    var browserId = storage.getItem(_browserIdKey);

    if (browserId == null || browserId.isEmpty) {
      // Generate new UUID for this browser
      browserId = const Uuid().v4();
      storage.setItem(_browserIdKey, browserId);
      AppLogger.info('[WebStorage] Generated new browser ID: $browserId');
    }

    return browserId;
  }

  /// Check if reaction is allowed for this event
  static bool canReact(String eventSlug) {
    final storage = web.window.localStorage;
    final key = '$_reactionPrefix$eventSlug';
    final lastReactionStr = storage.getItem(key);

    if (lastReactionStr == null) {
      return true; // Never reacted to this event
    }

    try {
      final lastReaction = DateTime.parse(lastReactionStr);
      final now = DateTime.now();
      final difference = now.difference(lastReaction);

      // Check if 1 hour has passed
      if (difference >= AppConstants.reactionRateLimit) {
        return true;
      }

      AppLogger.debug(
        '[WebStorage] Reaction rate limited. Time remaining: '
        '${AppConstants.reactionRateLimit.inSeconds - difference.inSeconds}s',
      );
      return false;
    } catch (e) {
      AppLogger.error('[WebStorage] Failed to parse last reaction time', e);
      return true; // Allow reaction if we can't parse the timestamp
    }
  }

  /// Record a reaction timestamp for this event
  static void recordReaction(String eventSlug) {
    final storage = web.window.localStorage;
    final key = '$_reactionPrefix$eventSlug';
    storage.setItem(key, DateTime.now().toIso8601String());
    AppLogger.debug('[WebStorage] Recorded reaction for: $eventSlug');
  }
}

/// Controller for public countdown screen
class PublicCountdownController extends GetxController {
  final String slug;
  final SharingRepo _sharingRepo = SharingRepo();

  PublicCountdownController({required this.slug});

  // State
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final Rxn<CountdownEvent> event = Rxn<CountdownEvent>();
  final reactionCount = 0.obs;
  final canReact = true.obs;
  final showReactionAnimation = false.obs;

  Timer? _reactionCooldownTimer;

  @override
  void onInit() {
    super.onInit();
    _loadEvent();
  }

  @override
  void onClose() {
    _reactionCooldownTimer?.cancel();
    super.onClose();
  }

  /// Load shared event from Appwrite
  Future<void> _loadEvent() async {
    try {
      AppLogger.info('[PublicCountdown] Loading shared event: $slug');
      isLoading.value = true;
      hasError.value = false;

      final data = await _sharingRepo.getSharedEvent(slug);

      if (data == null) {
        hasError.value = true;
        errorMessage.value = AppStrings.sharedEventNotFound;
        return;
      }

      // Convert to CountdownEvent model
      event.value = CountdownEvent(
        id: data['slug'],
        title: data['title'],
        targetDate: data['targetDate'],
        timezone: data['timezone'],
        colorValue: data['colorValue'],
        emoji: data['emoji'],
        isPinned: false,
        shareSlug: data['slug'],
        createdAt: data['eventCreatedAt'],
      );

      reactionCount.value = data['reactionCount'] ?? 0;

      AppLogger.info('[PublicCountdown] Event loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('[PublicCountdown] Failed to load event', e, stackTrace);
      hasError.value = true;
      errorMessage.value = AppStrings.failedToLoadCountdown;
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle double-tap reaction
  Future<void> handleReaction() async {
    if (!canReact.value) {
      AppLogger.debug('[PublicCountdown] Reaction on cooldown');
      return;
    }

    // Check localStorage rate limit
    if (!WebStorageHelper.canReact(slug)) {
      AppLogger.warning('[PublicCountdown] Reaction rate limited by localStorage');
      Get.snackbar(
        AppStrings.reactSlowDown,
        AppStrings.reactSlowDownMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        borderRadius: AppConstants.borderRadiusLarge,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      AppLogger.info('[PublicCountdown] Adding reaction');

      // Show animation immediately
      showReactionAnimation.value = true;
      Future.delayed(const Duration(milliseconds: 1500), () {
        showReactionAnimation.value = false;
      });

      // Get unique browser ID
      final browserId = WebStorageHelper.getBrowserId();

      // Add reaction to backend using browser ID
      final success = await _sharingRepo.addReaction(slug, browserId);

      if (success) {
        // Record reaction in localStorage
        WebStorageHelper.recordReaction(slug);

        // Increment local count
        reactionCount.value++;
        AppLogger.info('[PublicCountdown] Reaction added');

        // Start cooldown (3 seconds client-side)
        canReact.value = false;
        _reactionCooldownTimer?.cancel();
        _reactionCooldownTimer = Timer(const Duration(seconds: 3), () {
          canReact.value = true;
        });
      } else {
        // Rate limited by backend
        AppLogger.warning('[PublicCountdown] Reaction rate limited by backend');
        Get.snackbar(
          AppStrings.reactSlowDown,
          AppStrings.reactSlowDownMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.warning.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(AppConstants.paddingMedium),
          borderRadius: AppConstants.borderRadiusLarge,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      AppLogger.error('[PublicCountdown] Failed to add reaction', e);
    }
  }

  /// Retry loading
  void retry() {
    _loadEvent();
  }
}

/// Public countdown screen for web
class PublicCountdownScreen extends StatelessWidget {
  final String slug;

  const PublicCountdownScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PublicCountdownController>(
      init: PublicCountdownController(slug: slug),
      builder: (ctrl) {
        return Scaffold(
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return _buildLoadingState();
            }

            if (ctrl.hasError.value) {
              return _buildErrorState(ctrl);
            }

            if (ctrl.event.value == null) {
              return _buildNotFoundState();
            }

            return _buildCountdownContent(context, ctrl);
          }),
        );
      },
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Error state
  Widget _buildErrorState(PublicCountdownController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            AppStrings.oops,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ctrl.errorMessage.value,
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: ctrl.retry,
            child: Text(AppStrings.tryAgain),
          ),
        ],
      ),
    );
  }

  /// Not found state
  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            AppStrings.countdownNotFound,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.countdownNotFoundMessage,
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Countdown content (responsive layout)
  Widget _buildCountdownContent(
    BuildContext context,
    PublicCountdownController ctrl,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppConstants.breakpointTablet;
    final isMobile = screenWidth < AppConstants.breakpointMobile;

    return Stack(
      children: [
        // Main content
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop
                  ? AppConstants.maxWebContentWidth
                  : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile
                    ? AppConstants.paddingLarge
                    : AppConstants.paddingLarge * 2,
                vertical: AppConstants.paddingLarge * 2,
              ),
              child: GestureDetector(
                onDoubleTap: ctrl.handleReaction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Emoji and title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ctrl.event.value!.emoji,
                          style: TextStyle(
                            fontSize: isMobile
                                ? 48
                                : AppConstants.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Flexible(
                          child: Text(
                            ctrl.event.value!.title,
                            style: Get.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 20 : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Countdown display
                    CountdownDisplay(event: ctrl.event.value!),
                    const SizedBox(height: 48),
                    // Reaction counter
                    Obx(() => _buildReactionCounter(ctrl.reactionCount.value)),
                    const SizedBox(height: 24),
                    // Hint text
                    Text(
                      AppStrings.doubleTapToReact,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Reaction animation overlay
        Obx(
          () => ctrl.showReactionAnimation.value
              ? _buildReactionAnimationOverlay()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Reaction counter widget
  Widget _buildReactionCounter(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.dividerDark, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('❤️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            count == 0
                ? AppStrings.beFirstToReact
                : count == 1
                ? AppStrings.onePersonReacted
                : '$count ${AppStrings.peopleReacted}',
            style: Get.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Footer with app link
  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          width: 100,
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.createYourOwnCountdown,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // TODO: Link to app store/play store
          },
          child: Text(AppStrings.getTheApp),
        ),
      ],
    );
  }

  /// Floating heart animation overlay
  Widget _buildReactionAnimationOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -100 * value),
                child: Opacity(
                  opacity: 1.0 - value,
                  child: Transform.scale(
                    scale: 0.5 + (value * 1.5),
                    child: const Text('❤️', style: TextStyle(fontSize: 80)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
