# Countdown App

A beautiful, local-first event countdown app with shareable mini-pages.

## Features

- 📅 Create unlimited countdowns with custom colors and emojis
- 🔗 Shareable public links with live countdown timers
- ❤️ Interactive reactions on shared pages
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

# Run web
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart              # Mobile entry
├── main_web.dart          # Web entry (coming soon)
├── app/                   # App-wide configuration (colors, strings, theme, etc.)
├── models/                # Data models (CountdownEvent, UserProfile)
├── repositories/          # API/data layer
├── screens/               # Mobile screens (controller + view in same file)
├── services/              # Core services (storage, API)
├── utils/                 # Pure utility functions (date_utils, operation_scope)
├── view_models/           # UI formatting view models (pure - no state)
├── widgets/               # Reusable components (AppLoading, AppFutureBuilder)
└── web/                   # Web-specific screens (coming soon)
```

## Documentation

- [Technical Specification](.claude/SPEC.md)
- [Development Roadmap](.claude/TODO.md)

## License

Proprietary - © 2025 dashwhiz
