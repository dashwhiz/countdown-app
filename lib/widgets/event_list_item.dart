import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../models/countdown_event.dart';
import '../view_models/event_view_model.dart';

class EventListItem extends StatelessWidget {
  const EventListItem({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDeleteConfirmed,
    required this.onTogglePin,
    required this.onDismissed,
    this.showDivider = true,
  });

  final CountdownEvent event;
  final VoidCallback onTap;
  final Future<bool> Function() onDeleteConfirmed;
  final VoidCallback onTogglePin;
  final VoidCallback onDismissed;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final vm = EventViewModel(event);

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog and return result
        return await onDeleteConfirmed();
      },
      onDismissed: (direction) {
        // Called after confirmDismiss returns true
        onDismissed();
      },
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              child: Row(
                children: [
                  // Emoji
                  Text(event.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: AppConstants.paddingMedium),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.formattedTimeRemaining,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: event.hasEnded
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: event.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vm.formattedDate,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: event.color,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pin/Unpin Icon
                  IconButton(
                    onPressed: onTogglePin,
                    icon: Icon(
                      event.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: event.isPinned ? AppColors.primary : Colors.grey,
                    ),
                    tooltip: event.isPinned ? 'Unpin' : 'Pin',
                  ),
                ],
              ),
            ),
            // Divider with padding on sides
            if (showDivider)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: Container(
                  height: 0.5,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
