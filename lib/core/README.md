# Core Utilities

This folder contains app-wide constants, themes, and utilities for maintaining consistency across the app.

## Files

### app_strings.dart
Centralized string constants for all UI text. Prepared for future localization.

**Usage:**
```dart
Text(AppStrings.homeTitle)
AppBar(title: Text(AppStrings.createTitle))
```

**Categories:**
- General UI (OK, Cancel, Delete, etc.)
- Screen titles and labels
- Time display units
- Error messages
- Pro feature labels

---

### app_colors.dart
Color palette for the entire app. Includes light/dark variants.

**Usage:**
```dart
Container(color: AppColors.primary)
Text(style: TextStyle(color: AppColors.textPrimary))
```

**Includes:**
- Primary, secondary, error colors (light/dark variants)
- Surface and background colors
- Text colors (primary/secondary)
- Divider and shadow colors
- **defaultEventColors** - 15 preset colors for countdown events
- **proGradientColors** - 8 gradient colors for Pro themes

---

### app_constants.dart
App-wide constants for dimensions, durations, and configuration.

**Usage:**
```dart
BorderRadius.circular(AppConstants.borderRadiusMedium)
Duration cooldown = AppConstants.reactionCooldown;
if (title.length > AppConstants.maxEventTitleLength) { ... }
```

**Categories:**
- **App metadata:** version, support email, URLs
- **Feature limits:** max title length, max pinned events
- **Animation durations:** fast, normal, slow
- **Rate limiting:** reaction cooldowns
- **UI dimensions:** padding, border radius, icon sizes
- **Responsive breakpoints:** mobile, tablet, desktop
- **Default emojis:** 20 preset emojis for events
- **Hive box names**
- **Pro purchase IDs**

---

### app_theme.dart
Complete Material 3 theme configuration for light and dark modes.

**Usage:**
```dart
GetMaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
)
```

**Configured components:**
- ColorScheme (from AppColors)
- Card theme
- AppBar theme
- FloatingActionButton theme
- ElevatedButton theme
- InputDecoration theme
- Divider theme
- SnackBar theme

All themes use constants from `app_colors.dart` and `app_constants.dart`.

---

## Benefits

✅ **Consistency** - All UI uses same colors, spacing, and strings
✅ **Maintainability** - Change colors/strings in one place
✅ **Localization ready** - All strings centralized
✅ **Type safety** - Constants prevent typos
✅ **Dark mode** - Full light/dark theme support
✅ **Responsive** - Breakpoints defined for all screen sizes

---

## Adding New Values

### New String
```dart
// app_strings.dart
static const String myNewString = 'Hello World';
```

### New Color
```dart
// app_colors.dart
static const Color myNewColor = Color(0xFF123456);
```

### New Constant
```dart
// app_constants.dart
static const double mySpacing = 20.0;
```

---

## Future Localization

When adding translations (e.g., German):
1. Create `lib/l10n/` folder
2. Add `intl` package configuration
3. Convert `AppStrings` to use `.arb` files
4. Generate translation files

For now, all strings are in English and ready to be extracted.
