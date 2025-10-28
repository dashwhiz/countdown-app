import 'package:flutter/material.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import 'event_list_item.dart';

class AllEventsSection extends StatelessWidget {
  const AllEventsSection({
    super.key,
    required this.unpinnedEvents,
    required this.onEventTap,
    required this.onDeleteConfirmed,
    required this.onTogglePin,
  });

  final List<CountdownEvent> unpinnedEvents;
  final Function(CountdownEvent) onEventTap;
  final Future<bool> Function(CountdownEvent) onDeleteConfirmed;
  final Function(String) onTogglePin;

  @override
  Widget build(BuildContext context) {
    if (unpinnedEvents.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: AppConstants.paddingSmall),
        // All section header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMedium,
            AppConstants.paddingSmall,
            AppConstants.paddingMedium,
            AppConstants.paddingSmall,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.allSection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        // All unpinned events
        ...unpinnedEvents.map((event) {
          return EventListItem(
            event: event,
            onTap: () => onEventTap(event),
            onDeleteConfirmed: () => onDeleteConfirmed(event),
            onDismissed: () {},
            onTogglePin: () => onTogglePin(event.id),
            showDivider: false,
          );
        }),
      ],
    );
  }
}
