import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz),
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppConstants.borderRadiusLarge,
        ),
      ),
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.cardLight
          : AppColors.cardDark,
      elevation: 8,
      onSelected: (value) {
        // TODO: Implement menu actions
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'restore',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.restore,
                size: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.restorePurchases),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'privacy',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.privacyPolicy),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'support',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.helpAndSupport),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.about),
            ],
          ),
        ),
      ],
    );
  }
}
