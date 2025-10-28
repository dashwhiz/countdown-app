import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';

class ColorPickerGrid extends StatelessWidget {
  const ColorPickerGrid({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingSmall,
      children: AppColors.defaultEventColors.map((color) {
        final isSelected = color.toARGB32() == selectedColor.toARGB32();
        final colorHex = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
        return Semantics(
          label: 'Color option $colorHex',
          selected: isSelected,
          button: true,
          child: GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
