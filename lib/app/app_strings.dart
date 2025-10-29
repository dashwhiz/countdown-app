class AppStrings {
  AppStrings._();

  static const String appName = 'DazeToGo';

  // Storage
  static const String hiveBoxEvents = 'events';
  static const String hiveBoxProfile = 'profile';

  // URLs
  static const String shareUrlBase = 'https://dashwhiz.github.io/countdown-app';
  static const String privacyPolicyUrl =
      'https://dashwhiz.github.io/countdown-app-landing/privacy.html';
  static const String termsOfServiceUrl =
      'https://dashwhiz.github.io/countdown-app-landing/terms.html';
  static const String supportUrl =
      'https://dashwhiz.github.io/countdown-app-landing/#help-support';
  static const String aboutUrl =
      'https://dashwhiz.github.io/countdown-app-landing/about.html';

  // Pro
  static const String proPurchaseId = 'countdown_pro_lifetime';

  // General
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String save = 'Save';
  static const String share = 'Share';
  static const String close = 'Close';
  static const String retry = 'Retry';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Tooltips
  static const String tooltipCreateCountdown = 'Create new countdown';
  static const String tooltipEditCountdown = 'Edit countdown';
  static const String tooltipShareCountdown = 'Share countdown';
  static const String tooltipBack = 'Go back';
  static const String tooltipClose = 'Close';
  static const String tooltipMenu = 'Menu';

  // Dialog Titles
  static const String errorTitle = 'Error';
  static const String successTitle = 'Success';
  static const String confirmTitle = 'Confirm';
  static const String infoTitle = 'Information';

  // Home Screen
  static const String homeTitle = 'My Countdowns';
  static const String pinnedSection = 'Pins';
  static const String allSection = 'All';
  static const String emptyStateTitle = 'No countdowns yet';
  static const String emptyStateMessage =
      'Tap + to create your first countdown';
  static const String deleteCountdownTitle = 'Delete Countdown?';
  static const String deleteCountdownMessage = 'This action cannot be undone.';
  static const String pin = 'Pin';
  static const String unpin = 'Unpin';
  static const String viewAllPinned = 'View all';

  // Create/Edit Screen
  static const String createTitle = 'Create';
  static const String editTitle = 'Edit';
  static const String eventTitleLabel = 'Event Title';
  static const String eventTitleHint = 'Enter event name';
  static const String dateTimeLabel = 'Date & Time';
  static const String colorLabel = 'Color';
  static const String emojiLabel = 'Emoji';
  static const String pinEvent = 'Pin to Top';
  static const String eventTitleRequired = 'Please enter a title';
  static const String unsavedChangesTitle = 'Discard Changes?';
  static const String unsavedChangesMessage =
      'You have unsaved changes. Are you sure you want to discard them?';
  static const String discardNewEventTitle = 'Discard New Event?';
  static const String discardNewEventMessage =
      'Your event data will be lost. Are you sure you want to go back?';
  static const String discard = 'Discard';

  // Detail Screen
  static const String detailsTitle = 'Details';
  static const String shareEvent = 'Share Countdown';
  static const String linkCopied = 'Link copied!';
  static const String copyLink = 'Copy Link';
  static const String pinToTop = 'Pin to Top';
  static const String unpinFromTop = 'Unpin';
  static const String deleteEvent = 'Delete Event';
  static const String endedOn = 'Ended on:';
  static const String endsOn = 'Ends on:';
  static const String comingSoonTitle = 'Coming Soon';
  static const String comingSoonSharingMessage =
      'Sharing feature will be available in the next update!';

  // Time Display
  static const String days = 'Day(s)';
  static const String hours = 'Hour(s)';
  static const String minutes = 'Minute(s)';
  static const String seconds = 'Second(s)';
  static const String day = 'day';
  static const String hour = 'hour';
  static const String minute = 'minute';
  static const String second = 'second';
  static const String eventEnded = 'Event ended';
  static const String timeRemaining = 'Time remaining';

  // Sharing
  static const String shareMessage = 'Check out my countdown:';
  static const String sharePromoMessage =
      'Check out my countdown! Track your special moments with Countdown App 🎉';
  static const String sharedEventNotFound = 'Countdown not found';
  static const String loadingEvent = 'Loading countdown...';
  static const String shareFailed = 'Share Failed';
  static const String shareFailedMessage =
      'Could not share the countdown. Please try again.';
  static const String createShareFailed = 'Failed to create share link';

  // Reactions
  static const String reactions = 'reactions';
  static const String peopleReacted = 'people reacted';
  static const String onePersonReacted = '1 person reacted';
  static const String noReactionsYet = 'No reactions yet';
  static const String beFirstToReact = 'Be the first to react!';
  static const String alreadyReacted = 'Already reacted';
  static const String alreadyReactedMessage = 'You can only react once';
  static const String reactSlowDown = 'Slow Down!';
  static const String reactSlowDownMessage = 'You can only react once per hour';
  static const String doubleTapToReact = 'Double-tap anywhere to react ❤️';
  static const String loadingReactions = 'Loading reactions...';

  // Pro Features
  static const String proTitle = 'Upgrade to Pro';
  static const String proPrice = '€4.99';
  static const String proUnlock = 'Unlock Pro';
  static const String proPurchaseButton = 'Unlock Pro - €4.99';
  static const String proFeatureLocked = 'Pro Feature';
  static const String proThemesTitle = 'Premium Themes';
  static const String proIconsTitle = 'Icon Library';
  static const String proVanitySlugTitle = 'Custom Links';
  static const String proWidgetsTitle = 'Pro Widgets';
  static const String proRecurringTitle = 'Recurring Countdowns';
  static const String proExportTitle = 'Image Export';

  // Web Pages
  static const String invalidLink = 'Invalid Link';
  static const String invalidLinkMessage = 'This countdown link is not valid.';
  static const String getTheApp = 'Get the App';
  static const String createYourOwnCountdown = 'Create your own countdown';
  static const String countdownNotFound = 'Countdown Not Found';
  static const String countdownNotFoundMessage =
      'This countdown may have been deleted or the link is incorrect.';
  static const String oops = 'Oops!';
  static const String failedToLoadCountdown =
      'Failed to load countdown. Please try again.';
  static const String tryAgain = 'Try Again';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork =
      'Network error. Please check your internet connection.';
  static const String errorNetworkShort =
      'Network error. Please check your internet connection.';
  static const String errorRateLimit =
      'Too many requests. Please try again in a moment.';
  static const String errorNotFound = 'Content not found.';
  static const String errorUnexpected = 'An unexpected error occurred.';
  static const String errorLoadingEvent = 'Failed to load countdown';
  static const String errorSharingEvent = 'Failed to share countdown';
  static const String errorDeletingEvent = 'Failed to delete countdown';
  static const String errorInitialization = 'Failed to Initialize';
  static const String errorInitializationMessage =
      'We couldn\'t start the app. Please try again.';
  static const String errorOfflineMessage =
      'Please check your internet connection';
  static const String errorTimeoutMessage =
      'Connection timeout. Please try again';
  static const String errorUnknownMessage = 'An unexpected error occurred';
  static const String retryButton = 'Retry';
  static const String errorCreateShareLink =
      'Failed to create shareable link. Please try again.';

  // Menu
  static const String restorePurchases = 'Restore Purchases';
  static const String privacyPolicy = 'Privacy Policy';
  static const String helpAndSupport = 'Help & Support';
  static const String about = 'About';

  // Settings (future)
  static const String settingsTitle = 'Settings';
  static const String notificationsTitle = 'Notifications';
  static const String themesTitle = 'Themes';
  static const String aboutTitle = 'About';
  static const String termsOfService = 'Terms of Service';
  static const String supportEmail = 'dashwhiz@gmail.com';
  static const String contactSupport = 'Contact Support';
}
