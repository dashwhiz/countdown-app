import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_error_listeners.dart';
import '../app/app_logger.dart';
import '../app/app_progress_listeners.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../repositories/events_repo.dart';
import '../repositories/sharing_repo.dart';
import '../utils/operation_scope.dart';
import '../widgets/all_events_section.dart';
import '../widgets/app_confirmation_dialog.dart';
import '../widgets/app_future_builder.dart';
import '../widgets/app_menu_button.dart';
import '../widgets/pinned_events_section.dart';
import 'create_edit_event_screen.dart';
import 'detail_screen.dart';

class HomeController extends GetxController {
  final EventsRepo _repo = EventsRepo();
  final SharingRepo _sharingRepo = SharingRepo();

  late ProgressListener _progressListener;
  late ErrorListener _errorListener;

  List<CountdownEvent> allEvents = [];
  late final Future<void> initFuture;

  List<CountdownEvent> get pinnedEvents =>
      allEvents.where((e) => e.isPinned).toList()..sort(_sortByOngoingFirst);

  List<CountdownEvent> get unpinnedEvents =>
      allEvents.where((e) => !e.isPinned).toList()..sort(_sortByOngoingFirst);

  // Sort ongoing events first (by date), then ended events (by date)
  int _sortByOngoingFirst(CountdownEvent a, CountdownEvent b) {
    final aEnded = a.hasEnded;
    final bEnded = b.hasEnded;

    // If one has ended and the other hasn't, show ongoing first
    if (aEnded && !bEnded) return 1;
    if (!aEnded && bEnded) return -1;

    // Both ongoing or both ended - sort by date (earliest first)
    return a.targetDate.compareTo(b.targetDate);
  }

  @override
  void onInit() {
    super.onInit();
    final context = Get.context;
    if (context != null) {
      _progressListener = DefaultProgressListener(context);
      _errorListener = DialogErrorListener(context);
    } else {
      AppLogger.error('Context is null during HomeController initialization');
    }
    initFuture = _initialize();
  }

  // Initial load for FutureBuilder (no progress dialog, FutureBuilder handles loading UI)
  Future<void> _initialize() async {
    allEvents = await _repo.getAllEvents();
    update();
  }

  Future<void> loadEvents() async {
    final result = await scope(
      scope: () async => await _repo.getAllEvents(),
      progressListener: _progressListener,
      errorListener: _errorListener,
    );

    if (result.success && result.result != null) {
      allEvents = result.result!;
      update();
    }
  }

  Future<void> togglePin(String id) async {
    try {
      final success = await _repo.togglePin(id);
      if (success) {
        await loadEvents();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle pin', e, stackTrace);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      final success = await _repo.deleteEvent(id);
      if (success) {
        await loadEvents();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete event', e, stackTrace);
    }
  }

  Future<void> handleDeleteSharedData(BuildContext context) async {
    // Count shared events
    final sharedEvents = allEvents.where((e) => e.shareSlug != null).toList();

    if (sharedEvents.isEmpty) {
      Get.snackbar(
        AppStrings.noSharedDataTitle,
        AppStrings.noSharedData,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        borderRadius: AppConstants.borderRadiusLarge,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: AppStrings.deleteSharedDataTitle,
      message: AppStrings.deleteSharedDataMessage,
      confirmText: AppStrings.delete,
      cancelText: AppStrings.cancel,
      icon: Icons.delete_forever,
      isDestructive: true,
    );

    if (confirmed != true) return;

    // Delete shared data
    final result = await scope(
      scope: () async => await _sharingRepo.deleteAllSharedEvents(allEvents),
      progressListener: _progressListener,
      errorListener: _errorListener,
    );

    if (result.success && result.result != null) {
      final deletedCount = result.result!;

      // Clear shareSlug and deletionToken from local events
      for (final event in sharedEvents) {
        final updatedEvent = CountdownEvent(
          id: event.id,
          title: event.title,
          targetDate: event.targetDate,
          timezone: event.timezone,
          colorValue: event.colorValue,
          emoji: event.emoji,
          isPinned: event.isPinned,
          shareSlug: null, // Clear share slug
          vanitySlug: event.vanitySlug,
          themeId: event.themeId,
          deletionToken: null, // Clear deletion token
          createdAt: event.createdAt,
        );
        await _repo.saveEvent(updatedEvent);
      }

      // Reload events
      await loadEvents();

      // Show success message
      final message = deletedCount == sharedEvents.length
          ? AppStrings.deleteSharedDataSuccess
          : AppStrings.deleteSharedDataPartial;

      Get.snackbar(
        AppStrings.successTitle,
        '$message ($deletedCount/${sharedEvents.length})',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        borderRadius: AppConstants.borderRadiusLarge,
      );
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              AppStrings.homeTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              // Plus button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: AppStrings.tooltipCreateCountdown,
                  onPressed: () async {
                    final result = await Get.to(
                      () => const CreateEditEventScreen(),
                    );
                    if (result == true) {
                      await ctrl.loadEvents();
                    }
                  },
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                ),
              ),
              // Menu button
              AppMenuButton(
                onDeleteSharedData: () => ctrl.handleDeleteSharedData(context),
              ),
            ],
          ),
          body: AppFutureBuilder<void>(
            future: ctrl.initFuture,
            dataBuilder: (context, _) => _buildBody(context, ctrl),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeController ctrl) {
    if (ctrl.allEvents.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: ctrl.loadEvents,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: AppConstants.paddingSmall),
          PinnedEventsSection(
            pinnedEvents: ctrl.pinnedEvents,
            onEventTap: (event) async {
              final result = await Get.to(() => DetailScreen(event: event));
              if (result == true) {
                await ctrl.loadEvents();
              }
            },
            onDeleteConfirmed: (event) =>
                _showDeleteConfirmation(context, event, ctrl),
            onTogglePin: ctrl.togglePin,
          ),
          AllEventsSection(
            unpinnedEvents: ctrl.unpinnedEvents,
            onEventTap: (event) async {
              final result = await Get.to(() => DetailScreen(event: event));
              if (result == true) {
                await ctrl.loadEvents();
              }
            },
            onDeleteConfirmed: (event) =>
                _showDeleteConfirmation(context, event, ctrl),
            onTogglePin: ctrl.togglePin,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: AppConstants.iconSizeGiant,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            AppStrings.emptyStateTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            AppStrings.emptyStateMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    CountdownEvent event,
    HomeController ctrl,
  ) async {
    final result = await AppConfirmationDialog.show(
      context: context,
      icon: Icons.delete_outline,
      title: AppStrings.deleteCountdownTitle,
      message: '${AppStrings.deleteCountdownMessage}\n\n"${event.title}"',
      confirmText: AppStrings.delete,
      cancelText: AppStrings.cancel,
      isDestructive: true,
    );

    // If user confirmed, delete the event
    if (result) {
      await ctrl.deleteEvent(event.id);
      return true; // Allow dismissal
    }

    return false; // Cancel dismissal
  }
}
