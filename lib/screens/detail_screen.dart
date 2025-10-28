import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../repositories/events_repo.dart';
import '../widgets/countdown_display.dart';
import 'create_edit_event_screen.dart';

class DetailController extends GetxController {
  CountdownEvent event;
  final EventsRepo _repo = EventsRepo();
  bool wasEdited = false;

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

  void handleShare() {
    // Placeholder for Phase 2
    Get.snackbar(
      'Coming Soon',
      'Sharing feature will be available in the next update!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardDark,
      colorText: AppColors.textPrimaryDark,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      borderRadius: AppConstants.borderRadiusLarge,
    );
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
                    onPressed: ctrl.navigateToEdit,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: ctrl.handleShare,
                ),
                const SizedBox(width: 8),
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
                              style: const TextStyle(fontSize: 64),
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
