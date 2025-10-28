import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';

class DateTimePicker {
  DateTimePicker._();

  /// Shows a styled Material date picker followed by a time picker.
  /// Returns the combined DateTime if both are selected, null otherwise.
  /// Enforces a minimum date/time constraint.
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDateTime,
    required DateTime minimumDateTime,
    required DateTime maximumDateTime,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime.isBefore(minimumDateTime)
          ? minimumDateTime
          : initialDateTime,
      firstDate: minimumDateTime,
      lastDate: maximumDateTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? AppColors.cardLight
                  : AppColors.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusLarge),
              ),
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.cardLight
                    : AppColors.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
                dialBackgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppColors.surface
                        : AppColors.surfaceDark,
                hourMinuteColor: AppColors.primary.withValues(alpha: 0.1),
                hourMinuteTextColor: AppColors.primary,
                dayPeriodColor: AppColors.primary.withValues(alpha: 0.1),
                dayPeriodTextColor: AppColors.primary,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Validate that the combined date/time meets minimum constraint
        if (newDateTime.isAfter(minimumDateTime) ||
            newDateTime.isAtSameMomentAs(minimumDateTime)) {
          return newDateTime;
        }
      }
    }

    return null;
  }
}
