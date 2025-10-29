# Countdown App

A beautiful, local-first event countdown app with shareable mini-pages.

## Features

- 📅 Create unlimited countdowns with custom colors (21 colors) and emojis (35+ options)
- 📌 Pin important events with dedicated pinned section
- 🌙 Beautiful dark mode UI with iOS-style animations
- 🔗 Shareable public links with live countdown timers
- ❤️ Interactive reactions on shared pages (with rate limiting)
- 🎨 Pro themes and icon packs (v1.2)
- 📱 Home/lock screen widgets (iOS & Android)

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** GetX
- **Local Storage:** Hive
- **Backend:** Appwrite
- **Platforms:** iOS, Android, Web

## Setup

### Prerequisites
- Flutter SDK (latest stable)
- iOS: Xcode 15+ / Android: Android Studio

### Installation

```bash
# Install dependencies
flutter pub get

# Generate Hive type adapters
flutter pub run build_runner build

# Run mobile
flutter run

# Run web locally
flutter run -d chrome --target lib/main_web.dart

# Build for web deployment
flutter build web --release --base-href "/countdown-app/" --target lib/main_web.dart
```

## Live Demo

🌐 **Web App:** [https://dashwhiz.github.io/countdown-app/](https://dashwhiz.github.io/countdown-app/)

Visit any shared countdown link (e.g., `?id=abc123xyz`) to see the public countdown page with live reactions!

## Project Structure

```
lib/
├── main.dart              # Mobile entry point
├── main_web.dart          # Web entry point (deployed on GitHub Pages)
├── app/                   # App-wide configuration (colors, strings, theme, etc.)
├── models/                # Data models (CountdownEvent, UserProfile)
├── repositories/          # API/data layer
├── screens/               # Mobile screens (controller + view in same file)
├── services/              # Core services (Appwrite, storage)
├── utils/                 # Pure utility functions (date_utils, operation_scope)
├── view_models/           # UI formatting view models (pure - no state)
├── widgets/               # Reusable components (AppLoading, AppFutureBuilder)
└── web/                   # Web-specific screens (PublicCountdownScreen)
```

## App Icons

The app features a custom purple gradient icon with a calendar design:
- iOS: 15 icon sizes (20x20 to 1024x1024)
- Android: Standard + adaptive icons (5 densities)
- Web: Favicon + PWA icons (192px, 512px)

Icons are generated using `flutter_launcher_icons`.

## License

Proprietary - © 2025 dashwhiz
