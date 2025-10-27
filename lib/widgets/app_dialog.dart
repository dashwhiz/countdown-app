import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';

class AppDialog {
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppConstants.iconSizeLarge,
            ),
            const SizedBox(width: 12),
            Text(
              title ?? AppStrings.errorTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text(AppStrings.retry),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: AppConstants.iconSizeLarge,
            ),
            const SizedBox(width: 12),
            Text(
              title ?? AppStrings.successTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String message,
    String? title,
    String confirmText = AppStrings.yes,
    String cancelText = AppStrings.no,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isDestructive ? Icons.warning_outlined : Icons.help_outline,
              color: isDestructive ? AppColors.warning : AppColors.primary,
              size: AppConstants.iconSizeLarge,
            ),
            const SizedBox(width: 12),
            Text(
              title ?? AppStrings.confirmTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String message,
    String? title,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: AppConstants.iconSizeLarge,
            ),
            const SizedBox(width: 12),
            Text(
              title ?? AppStrings.infoTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}
