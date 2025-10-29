import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../utils/helper_functions.dart';
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

    return Semantics(
      label: '${event.title} countdown',
      hint: event.isPinned
          ? 'Swipe right to unpin, swipe left to delete'
          : 'Swipe right to pin, swipe left to delete',
      child: Dismissible(
        key: ValueKey(event.id),
        direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: event.isPinned ? AppColors.warning : AppColors.success,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              event.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              event.isPinned ? AppStrings.unpin : AppStrings.pin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - delete with confirmation
          return await onDeleteConfirmed();
        } else {
          // Swipe right - pin/unpin immediately
          onTogglePin();
          return false; // Don't dismiss, just toggle pin
        }
      },
      onDismissed: (direction) {
        // Called after confirmDismiss returns true (only for delete)
        onDismissed();
      },
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  // Emoji in circular container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.dividerDark,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        event.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Color line indicator (height of title)
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      HelperFunctions.capitalizeFirst(event.title),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (event.isPinned) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.push_pin,
                                      size: 20,
                                      color: AppColors.warning,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.formattedTimeRemaining,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: event.hasEnded
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  // Chevron icon
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryDark,
                    size: 24,
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
                  height: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
