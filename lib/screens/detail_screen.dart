import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_logger.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../repositories/events_repo.dart';
import '../repositories/sharing_repo.dart';
import '../widgets/countdown_display.dart';
import 'create_edit_event_screen.dart';

class DetailController extends GetxController {
  CountdownEvent event;
  final EventsRepo _repo = EventsRepo();
  final SharingRepo _sharingRepo = SharingRepo();
  bool wasEdited = false;

  // Reaction count (only if event is shared)
  final reactionCount = Rxn<int>();
  final isLoadingReactions = false.obs;

  DetailController({required this.event});

  @override
  void onInit() {
    super.onInit();
    // Load reaction count if event is shared
    if (event.isShared) {
      _loadReactionCount();
    }
  }

  /// Load reaction count from Appwrite
  Future<void> _loadReactionCount() async {
    try {
      isLoadingReactions.value = true;
      final count = await _sharingRepo.getReactionCount(event.shareSlug!);
      reactionCount.value = count;
      AppLogger.debug('[DetailController] Reaction count: $count');
    } catch (e) {
      AppLogger.error('[DetailController] Failed to load reactions', e);
      reactionCount.value = null;
    } finally {
      isLoadingReactions.value = false;
    }
  }

  /// Refresh reaction count
  Future<void> refreshReactions() async {
    if (event.isShared) {
      await _loadReactionCount();
    }
  }

  Future<void> navigateToEdit() async {
    final result = await Get.to(
      () => CreateEditEventScreen(eventToEdit: event),
    );
    if (result == true) {
      // Reload the event from the repository
      final allEvents = await _repo.getAllEvents();
      final updatedEvent = allEvents.firstWhereOrNull((e) => e.id == event.id);
      if (updatedEvent != null) {
        event = updatedEvent;
        wasEdited = true;
        update();
      }
    }
  }

  void navigateBack() {
    Get.back(result: wasEdited);
  }

  Future<void> handleShare(BuildContext context) async {
    try {
      AppLogger.info('[DetailController] Starting share process...');

      // Get the share button's position BEFORE any async operations
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      // Create or get existing share slug
      final slug = await _sharingRepo.createOrGetShareSlug(event);

      if (slug == null) {
        throw Exception(AppStrings.createShareFailed);
      }

      // If this is a new share, update the local event with the slug
      if (event.shareSlug != slug) {
        final updatedEvent = event.copyWith(shareSlug: slug);
        await _repo.saveEvent(updatedEvent);
        event = updatedEvent;
        wasEdited = true;
        update();

        // Load reaction count for the newly shared event
        await _loadReactionCount();
      }

      // Build the shareable URL
      // TODO: Replace with your actual domain when web app is deployed
      final shareUrl = '${AppConstants.shareUrlBase}/?id=$slug';

      // Share using native share dialog with promotional text
      final shareText = '${AppStrings.sharePromoMessage}\n\n$shareUrl';
      await Share.share(
        shareText,
        subject: '${event.emoji} ${event.title}',
        sharePositionOrigin: sharePositionOrigin,
      );

      AppLogger.info('[DetailController] Share successful: $shareUrl');
    } catch (e, stackTrace) {
      AppLogger.error('[DetailController] Share failed', e, stackTrace);

      // Show user-friendly error message
      Get.snackbar(
        AppStrings.shareFailed,
        AppStrings.shareFailedMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        borderRadius: AppConstants.borderRadiusLarge,
        duration: const Duration(seconds: 3),
      );
    }
  }

  String get formattedTargetDate {
    return DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(event.targetDate);
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.event});

  final CountdownEvent event;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailController>(
      init: DetailController(event: event),
      builder: (ctrl) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            // Only handle if the pop hasn't happened yet
            if (!didPop) {
              ctrl.navigateBack();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: AppStrings.tooltipBack,
                onPressed: ctrl.navigateBack,
              ),
              title: const Text(
                AppStrings.detailsTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: AppStrings.tooltipEditCountdown,
                  onPressed: ctrl.navigateToEdit,
                  color: AppColors.primaryLight,
                ),
                Builder(
                  builder: (btnContext) => IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: AppStrings.tooltipShareCountdown,
                    onPressed: () => ctrl.handleShare(btnContext),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: AppConstants.paddingMedium),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingLarge,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppConstants.paddingLarge),
                        // Emoji and title in a row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ctrl.event.emoji,
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeLarge,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Flexible(
                              child: Text(
                                ctrl.event.title,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingLarge * 2),
                        // Countdown display (isolated StatefulWidget)
                        CountdownDisplay(event: ctrl.event),
                        const SizedBox(height: AppConstants.paddingLarge * 2),
                        // Reaction counter (if event is shared)
                        if (ctrl.event.isShared) ...[
                          Obx(() => _buildReactionCounter(context, ctrl)),
                          const SizedBox(height: AppConstants.paddingLarge * 2),
                        ],
                        // Target date
                        Text(
                          ctrl.event.targetDate.isBefore(DateTime.now())
                              ? AppStrings.endedOn
                              : AppStrings.endsOn,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          ctrl.formattedTargetDate,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build reaction counter widget
  Widget _buildReactionCounter(BuildContext context, DetailController ctrl) {
    if (ctrl.isLoadingReactions.value) {
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
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.loadingReactions),
          ],
        ),
      );
    }

    final count = ctrl.reactionCount.value ?? 0;

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
          const Text('❤️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            count == 0
                ? AppStrings.noReactionsYet
                : count == 1
                ? AppStrings.onePersonReacted
                : '$count ${AppStrings.peopleReacted}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: ctrl.refreshReactions,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
