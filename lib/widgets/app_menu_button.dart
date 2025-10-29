import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String _version = '...';

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
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = 'v${packageInfo.version}';
      });
    } catch (e) {
      setState(() {
        _version = 'v1.0.0';
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      // Failed to launch URL
    }
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
      onSelected: (value) async {
        _animationController.reverse();

        switch (value) {
          case 'about':
            await _launchUrl(AppStrings.aboutUrl);
            break;
          case 'privacy':
            await _launchUrl(AppStrings.privacyPolicyUrl);
            break;
          case 'terms':
            await _launchUrl(AppStrings.termsOfServiceUrl);
            break;
          case 'support':
            await _launchUrl(AppStrings.supportUrl);
            break;
        }
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
          enabled: false,
          height: 16,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: 0,
          ),
          child: Divider(height: 1, thickness: 1, color: AppColors.dividerDark),
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
          value: 'terms',
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 20),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text(AppStrings.termsOfService),
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
          child: Divider(height: 1, thickness: 1, color: AppColors.dividerDark),
        ),
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Text(
                _version,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
