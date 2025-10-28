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
import '../utils/operation_scope.dart';
import '../widgets/app_future_builder.dart';
import '../widgets/event_list_item.dart';
import 'create_edit_event_screen.dart';

class HomeController extends GetxController {
  final EventsRepo _repo = EventsRepo();

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
    _progressListener = DefaultProgressListener(Get.context!);
    _errorListener = DialogErrorListener(Get.context!);
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
              PopupMenuButton<String>(
                onSelected: (value) {
                  // TODO: Implement menu actions
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'restore',
                    child: Text(AppStrings.restorePurchases),
                  ),
                  const PopupMenuItem(
                    value: 'privacy',
                    child: Text(AppStrings.privacyPolicy),
                  ),
                  const PopupMenuItem(
                    value: 'support',
                    child: Text(AppStrings.helpAndSupport),
                  ),
                  const PopupMenuItem(
                    value: 'about',
                    child: Text(AppStrings.about),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ),
          body: AppFutureBuilder<void>(
            future: ctrl.initFuture,
            dataBuilder: (context, _) => _buildBody(context, ctrl),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Get.to(() => const CreateEditEventScreen());
              if (result == true) {
                await ctrl.loadEvents();
              }
            },
            child: const Icon(Icons.add),
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
          if (ctrl.pinnedEvents.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingMedium,
                AppConstants.paddingLarge,
                AppConstants.paddingMedium,
                AppConstants.paddingSmall,
              ),
              child: _buildSectionHeader(context, AppStrings.pinnedSection),
            ),
            ...ctrl.pinnedEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == ctrl.pinnedEvents.length - 1;

              return EventListItem(
                event: event,
                onTap: () async {
                  final result = await Get.to(
                    () => CreateEditEventScreen(eventToEdit: event),
                  );
                  if (result == true) {
                    await ctrl.loadEvents();
                  }
                },
                onDeleteConfirmed: () =>
                    _showDeleteConfirmation(context, event, ctrl),
                onDismissed: () {
                  // Item has been dismissed, controller will update
                },
                onTogglePin: () => ctrl.togglePin(event.id),
                showDivider: !isLast,
              );
            }),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
          if (ctrl.unpinnedEvents.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingMedium,
                ctrl.pinnedEvents.isEmpty ? AppConstants.paddingLarge : 0,
                AppConstants.paddingMedium,
                AppConstants.paddingSmall,
              ),
              child: _buildSectionHeader(context, AppStrings.allCountdowns),
            ),
            ...ctrl.unpinnedEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == ctrl.unpinnedEvents.length - 1;

              return EventListItem(
                event: event,
                onTap: () async {
                  final result = await Get.to(
                    () => CreateEditEventScreen(eventToEdit: event),
                  );
                  if (result == true) {
                    await ctrl.loadEvents();
                  }
                },
                onDeleteConfirmed: () =>
                    _showDeleteConfirmation(context, event, ctrl),
                onDismissed: () {
                  // Item has been dismissed, controller will update
                },
                onTogglePin: () => ctrl.togglePin(event.id),
                showDivider: !isLast,
              );
            }),
          ],
          const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            AppStrings.emptyStateTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            AppStrings.emptyStateMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    CountdownEvent event,
    HomeController ctrl,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteCountdownTitle),
        content: Text(
          '${AppStrings.deleteCountdownMessage}\n\n"${event.title}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    // If user confirmed, delete the event
    if (result == true) {
      await ctrl.deleteEvent(event.id);
      return true; // Allow dismissal
    }

    return false; // Cancel dismissal
  }
}
