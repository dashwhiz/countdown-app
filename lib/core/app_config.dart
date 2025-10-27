class AppConfig {
  AppConfig._();

  // Storage
  static const String hiveBoxEvents = 'events';
  static const String hiveBoxProfile = 'profile';

  // External URLs
  static const String shareUrlBase = 'https://countdown.app';
  static const String privacyPolicyUrl = 'https://countdown.app/privacy';
  static const String termsOfServiceUrl = 'https://countdown.app/terms';

  // Pro Features
  static const String proPurchaseId = 'countdown_pro_lifetime';
  static const String proPrice = '€4.99';

  // Snackbar Durations
  static const Duration snackbarShort = Duration(seconds: 2);
  static const Duration snackbarNormal = Duration(seconds: 3);
  static const Duration snackbarLong = Duration(seconds: 5);
}
