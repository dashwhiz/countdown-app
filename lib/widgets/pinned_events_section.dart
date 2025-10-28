import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import 'event_list_item.dart';

class PinnedEventsSection extends StatelessWidget {
  const PinnedEventsSection({
    super.key,
    required this.pinnedEvents,
    required this.onEventTap,
    required this.onDeleteConfirmed,
    required this.onTogglePin,
  });

  final List<CountdownEvent> pinnedEvents;
  final Function(CountdownEvent) onEventTap;
  final Future<bool> Function(CountdownEvent) onDeleteConfirmed;
  final Function(String) onTogglePin;

  @override
  Widget build(BuildContext context) {
    if (pinnedEvents.isEmpty) return const SizedBox.shrink();

    final displayedEvents = pinnedEvents.take(3).toList();
    final hasMore = pinnedEvents.length > 3;
    final hiddenCount = pinnedEvents.length - 3;

    return Column(
      children: [
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingMedium),
              // Pins header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.push_pin_outlined,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.pinnedSection,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              // Divider under title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: Container(height: 1, color: AppColors.dividerDark),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              // Display first 3 pinned events
              ...displayedEvents.map((event) {
                return EventListItem(
                  event: event,
                  onTap: () => onEventTap(event),
                  onDeleteConfirmed: () => onDeleteConfirmed(event),
                  onDismissed: () {},
                  onTogglePin: () => onTogglePin(event.id),
                  showDivider: false,
                );
              }),
              // View all button if more than 3
              if (hasMore) ...[
                const SizedBox(height: AppConstants.paddingSmall),
                TextButton(
                  onPressed: () => _showAllPinnedModal(context),
                  child: Text(
                    '${AppStrings.viewAllPinned} ($hiddenCount more)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.paddingMedium),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  void _showAllPinnedModal(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
          );

          return ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: _PinnedEventsModal(
                pinnedEvents: pinnedEvents,
                onEventTap: onEventTap,
                onDeleteConfirmed: onDeleteConfirmed,
                onTogglePin: onTogglePin,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PinnedEventsModal extends StatefulWidget {
  const _PinnedEventsModal({
    required this.pinnedEvents,
    required this.onEventTap,
    required this.onDeleteConfirmed,
    required this.onTogglePin,
  });

  final List<CountdownEvent> pinnedEvents;
  final Function(CountdownEvent) onEventTap;
  final Future<bool> Function(CountdownEvent) onDeleteConfirmed;
  final Function(String) onTogglePin;

  @override
  State<_PinnedEventsModal> createState() => _PinnedEventsModalState();
}

class _PinnedEventsModalState extends State<_PinnedEventsModal> {
  late List<CountdownEvent> displayedEvents;

  @override
  void initState() {
    super.initState();
    displayedEvents = List.from(widget.pinnedEvents);
  }

  @override
  Widget build(BuildContext context) {
    if (displayedEvents.isEmpty) {
      // Auto-close if no more pinned events
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button and title
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  // Close button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: AppStrings.tooltipClose,
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  // Centered title
                  Expanded(
                    child: Text(
                      AppStrings.pinnedSection,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Spacer to balance the close button
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // All pinned events
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
                itemCount: displayedEvents.length,
                itemBuilder: (context, index) {
                  final event = displayedEvents[index];
                  return EventListItem(
                    event: event,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onEventTap(event);
                    },
                    onDeleteConfirmed: () => widget.onDeleteConfirmed(event),
                    onDismissed: () {},
                    onTogglePin: () {
                      // Remove from local display
                      setState(() {
                        displayedEvents.removeWhere((e) => e.id == event.id);
                      });
                      // Update parent
                      widget.onTogglePin(event.id);
                    },
                    showDivider: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
