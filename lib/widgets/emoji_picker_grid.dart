import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';

class EmojiPickerGrid extends StatelessWidget {
  const EmojiPickerGrid({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  final String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingSmall,
      children: AppConstants.defaultEmojis.map((emoji) {
        final isSelected = emoji == selectedEmoji;
        return Semantics(
          label: 'Emoji $emoji',
          selected: isSelected,
          button: true,
          child: GestureDetector(
            onTap: () => onEmojiSelected(emoji),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
