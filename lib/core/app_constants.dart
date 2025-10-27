class AppConstants {
  AppConstants._();

  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  static const String supportEmail = 'dashwhiz@gmail.com';
  static const String privacyPolicyUrl = 'https://countdown.app/privacy';
  static const String termsOfServiceUrl = 'https://countdown.app/terms';

  static const int maxEventTitleLength = 100;
  static const int maxPinnedEvents = 3;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  static const Duration reactionCooldown = Duration(seconds: 3);
  static const Duration reactionRateLimit = Duration(hours: 1);

  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration snackbarDurationShort = Duration(seconds: 2);
  static const Duration snackbarDurationLong = Duration(seconds: 5);

  static const int maxReactionsPerEvent = 1000;

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
  ];

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  static const int responsiveBreakpointMobile = 600;
  static const int responsiveBreakpointTablet = 900;
  static const int responsiveBreakpointDesktop = 1200;

  static const double maxWebContentWidth = 600.0;

  static const String hiveBoxEvents = 'events';
  static const String hiveBoxProfile = 'profile';

  static const String proPurchaseId = 'countdown_pro_lifetime';
  static const String proPrice = '€4.99';

  static const String shareUrlBase = 'https://countdown.app';
}
