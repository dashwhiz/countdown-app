# App Icon Generation Guide

Generate all app icons (iOS, Android, Web) from your AppLogo design.

## Quick Steps

### 1. Export the Icon Image

**Option A: Using the Icon Export Screen (Easiest)**

1. Add this line to your `lib/screens/home_screen.dart` in the AppBar actions (temporarily):

```dart
IconButton(
  icon: const Icon(Icons.image),
  onPressed: () {
    Get.to(() => const IconExportScreen());
  },
),
```

2. Add the import:
```dart
import '../debug/icon_export_screen.dart';
```

3. Run the app: `flutter run`

4. Tap the image icon in the AppBar

5. Take a screenshot of the 1024x1024 icon displayed (or tap "Save to Photos")

6. Save it as `assets/icons/app_icon.png`

**Option B: Use Online Tool**

1. Go to https://www.figma.com or https://www.canva.com

2. Create a 1024x1024px canvas

3. Add gradient background:
   - Top-left: `#6750A4` (purple)
   - Bottom-right: `#4A3780` (dark purple)

4. Add rounded rectangle (corner radius: ~222px for 1024px size)

5. Add white calendar icon (centered, size ~512px)
   - You can use Material Icons or download from https://fonts.google.com/icons?icon.query=event

6. Export as PNG: `assets/icons/app_icon.png`

### 2. Create Foreground Icon (for Android Adaptive Icons)

Create a second version with transparent background:

1. Same as above but:
   - Background: transparent
   - Only the white calendar icon

2. Save as: `assets/icons/app_icon_foreground.png`

### 3. Generate All Icon Sizes

```bash
# Install dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons
```

This will automatically generate:
- ✅ iOS icons (all sizes from 20x20 to 1024x1024)
- ✅ Android icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Android adaptive icons (with background color)
- ✅ Web icons (favicon, 192x192, 512x512)

### 4. Verify

Check that icons were generated:
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android: `android/app/src/main/res/mipmap-*/`
- Web: `web/icons/` and `web/favicon.png`

### 5. Test

```bash
# Test on iOS
flutter run -d iPhone

# Test on Android
flutter run -d <android-device>

# Build and check icon appears
flutter build ios
flutter build apk
```

## Icon Specifications

**AppLogo Design:**
- Colors: Gradient from `#6750A4` to `#4A3780`
- Icon: Material Icons `event_available_rounded` (white)
- Corner Radius: 21.67% of size (iOS standard)
- Shadow: Optional (not needed for icons)

**Required Files:**
- `assets/icons/app_icon.png` - 1024x1024px, with gradient background
- `assets/icons/app_icon_foreground.png` - 1024x1024px, transparent background

**Generated Sizes:**
- iOS: 15 different sizes
- Android: 5 densities
- Web: Favicon (16x16) + PWA icons (192, 512)

## Configuration

The configuration is in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#6750A4"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  remove_alpha_ios: true
```

## Troubleshooting

**Icons not updating?**
```bash
# Clean build
flutter clean
flutter pub get

# Regenerate icons
flutter pub run flutter_launcher_icons

# Rebuild app
flutter run
```

**Android adaptive icon looks wrong?**
- Make sure foreground icon has transparent background
- Adjust `adaptive_icon_background` color in `pubspec.yaml`

**iOS icon has white edges?**
- Set `remove_alpha_ios: true` in config (already set)
- Make sure source image doesn't have transparency

## Web Deployment

After generating icons, update `gh-pages` branch:

```bash
# Build web with new icons
flutter build web --release --base-href "/countdown-app/" --target lib/main_web.dart

# Switch to gh-pages
git checkout gh-pages

# Update icons
cp build/web/favicon.png .
cp -r build/web/icons/* icons/

# Commit
git add favicon.png icons/
git commit -m "chore: update web app icons"
git push origin gh-pages

# Back to dev
git checkout dev
```

## Next Steps

After generating icons:
1. Test on all platforms
2. Commit to repository
3. Update web deployment (gh-pages branch)
4. Build for App Store / Play Store submission
