import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final isSharing = false.obs;

  DetailController({required this.event});

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

  Future<void> handleShare() async {
    try {
      isSharing.value = true;
      AppLogger.info('[DetailController] Starting share process...');

      // Create or get existing share slug
      final slug = await _sharingRepo.createOrGetShareSlug(event);

      if (slug == null) {
        throw Exception('Failed to create share link');
      }

      // If this is a new share, update the local event with the slug
      if (event.shareSlug != slug) {
        final updatedEvent = event.copyWith(shareSlug: slug);
        await _repo.saveEvent(updatedEvent);
        event = updatedEvent;
        wasEdited = true;
        update();
      }

      // Build the shareable URL
      // TODO: Replace with your actual domain when web app is deployed
      final shareUrl = 'https://fra.cloud.appwrite.io/?id=$slug';

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: shareUrl));

      // Show success message
      Get.snackbar(
        '🎉 Link Copied!',
        'Share this link with anyone to show your countdown',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        borderRadius: AppConstants.borderRadiusLarge,
        duration: const Duration(seconds: 3),
      );

      AppLogger.info('[DetailController] Share successful: $shareUrl');
    } catch (e, stackTrace) {
      AppLogger.error('[DetailController] Share failed', e, stackTrace);

      // Show error message
      Get.snackbar(
        'Share Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        borderRadius: AppConstants.borderRadiusLarge,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSharing.value = false;
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
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: AppStrings.tooltipEditCountdown,
                    onPressed: ctrl.navigateToEdit,
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  ),
                ),
                Obx(() => IconButton(
                  icon: ctrl.isSharing.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.share_outlined),
                  tooltip: AppStrings.tooltipShareCountdown,
                  onPressed: ctrl.isSharing.value ? null : ctrl.handleShare,
                )),
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
}
