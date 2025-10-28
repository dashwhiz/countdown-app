import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  static Future<bool> show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppConfirmationDialog(
        icon: icon,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Actions
            cancelText.isEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? AppColors.error
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall,
                          ),
                        ),
                      ),
                      child: Text(confirmText),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                          ),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDestructive
                                ? AppColors.error
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                          ),
                          child: Text(confirmText),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
