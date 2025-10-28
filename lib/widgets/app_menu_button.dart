import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';

class AppMenuButton extends StatefulWidget {
  const AppMenuButton({super.key});

  @override
  State<AppMenuButton> createState() => _AppMenuButtonState();
}

class _AppMenuButtonState extends State<AppMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: AppStrings.tooltipMenu,
      icon: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value == 0.0 ? 0.0 : _scaleAnimation.value,
            child: Opacity(
              opacity: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_horiz),
              ),
            ),
          );
        },
      ),
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      color: AppColors.surfaceDark.withValues(alpha: 0.9),
      elevation: 8,
      onOpened: () {
        _animationController.forward();
      },
      onCanceled: () {
        _animationController.reverse();
      },
      onSelected: (value) {
        _animationController.reverse();
        // TODO: Implement menu actions
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'about',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.about),
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
              const Icon(Icons.privacy_tip_outlined, size: 20),
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
              const Icon(Icons.help_outline, size: 20),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.helpAndSupport),
            ],
          ),
        ),
        PopupMenuItem(
          enabled: false,
          height: 16,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: 0,
          ),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.dividerDark,
          ),
        ),
        PopupMenuItem(
          value: 'restore',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              const Icon(Icons.restore, size: 20),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.restorePurchases),
            ],
          ),
        ),
      ],
    );
  }
}
