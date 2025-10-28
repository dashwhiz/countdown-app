class AppConstants {
  AppConstants._();
  // Feature Limits
  static const int maxEventTitleLength = 100;
  static const int maxPinnedEvents = 3;
  static const int maxReactionsPerEvent = 1000;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashAnimationPulse = Duration(milliseconds: 2000);
  static const Duration splashAnimationShimmer = Duration(milliseconds: 1800);

  // Rate Limiting
  static const Duration reactionCooldown = Duration(seconds: 3);
  static const Duration reactionRateLimit = Duration(hours: 1);

  // UI Dimensions
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 40.0;

  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 30.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;
  static const double iconSizeHuge = 64.0;
  static const double iconSizeGiant = 80.0;

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;

  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 64.0;

  static const double splashLogoSize = 160.0;
  static const double splashContainerSize = 180.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Responsive Breakpoints
  static const int breakpointMobile = 600;
  static const int breakpointTablet = 900;
  static const int breakpointDesktop = 1200;
  static const double maxWebContentWidth = 600.0;

  // Default Content
  static const String defaultEmoji = '🎉';
  static const List<String> defaultEmojis = [
    '🎉',
    '🎂',
    '🎄',
    '🎃',
    '💍',
    '✈️',
    '🎓',
    '🏆',
    '❤️',
    '🎁',
    '🌟',
    '🔥',
    '⏰',
    '📅',
    '🎊',
    '🥳',
    '💐',
    '🌈',
    '⭐',
    '💫',
    '🎈',
    '🎆',
    '✨',
    '🎯',
    '🎨',
    '🎬',
    '🎤',
    '🚀',
    '🏖️',
    '🎮',
    '⚽',
    '🎸',
    '🍾',
    '🏅',
    '🎭',
  ];
}
