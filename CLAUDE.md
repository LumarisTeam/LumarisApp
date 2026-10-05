# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

光序 is a cross-platform Flutter application for students at Xi'an University of Architecture and Technology. It provides course management, scheduling, exam information, grades, campus bus schedules, and more.

## Common Commands

### Development
```bash
flutter pub get                    # Install dependencies
flutter run                        # Run app in debug mode
flutter analyze                    # Run static analysis
dart format .                      # Format all code
```

### Code Generation
```bash
dart run build_runner build        # Generate freezed/json_serializable/hive code (one-shot)
dart run build_runner watch        # Watch mode — regenerates on file changes
```

### Testing
```bash
flutter test                                    # Run all tests
flutter test test/unit/course_model_test.dart  # Run single test file
flutter test --coverage                        # Generate coverage report
scripts/check_coverage.sh                      # Check coverage meets 80% threshold
```

### Platform-Specific Builds
```bash
# Android (APK)
flutter build apk --obfuscate --split-debug-info=xx --no-tree-shake-icons --target-platform android-arm64 --split-per-abi

# Android (AAB)
flutter build appbundle --obfuscate --split-debug-info=xx --no-tree-shake-icons --target-platform android-arm64

# iOS
flutter build ios       # or: flutter build ipa

# macOS
flutter build macos

# Web (WebAssembly)
flutter build web --no-tree-shake-icons --wasm

# Windows (MSIX store package)
dart run msix:create --store

# Linux
flutter build linux
```

## Architecture Overview

### State Management (Riverpod)

The app uses **flutter_riverpod** with `Notifier`/`AsyncNotifier` providers. Providers are defined alongside their state classes in `lib/state/`:

- `SettingsStore` / `settingsStoreProvider` — App settings, theme, locale, school selection
- `UserStore` / `userStoreProvider` — Authentication state and user profile
- `CourseStore` / `courseStoreProvider` — Course data
- `ScheduleStore` / `scheduleStoreProvider` — Weekly schedule views
- `ElectricityStore` / `electricityStoreProvider` — Dormitory electricity usage
- `PaymentStore` / `paymentStoreProvider` — Campus card payment records
- `BusTileStore` / `busTileStoreProvider` — Campus bus tile state
- `SchoolStore` / `schoolStoreProvider` — Current school configuration (loaded from API)

State is defined using **freezed** union types in `lib/state/app_states.dart`. Access providers via:

```dart
final store = ref.read(settingsStoreProvider.notifier);
final state = ref.watch(settingsStoreProvider);
```

Some legacy GetX-style stores (e.g., `BusTileStore`, `CourseStore`) remain in `lib/state/` during migration. New code should use Riverpod providers.

### Navigation (GoRouter)

Routes are defined in `lib/routes/router.dart` using `GoRouter`. The router is provided via Riverpod as `appRouterProvider`.

The app shell adapts per platform in `lib/main_app.dart`:
- **macOS**: `MacosShell` with `MacosSidebar` (window uses the system title bar)
- **Windows/Linux**: `WindowsSidebar` (Fluent Design style)
- **Tablet** (width > 600): `NavigationRail`-based layout
- **Mobile**: Bottom navigation bar (shown only on 4 main routes: home, schedule, score, profile)

Navigation methods:
```dart
AppRouter.go('/Schedule');           // Navigate to route
AppRouter.push('/Login');            // Push route onto stack
AppRouter.pop();                     // Pop current route
```

### Directory Structure

```
lib/
├── core/                     # Platform-agnostic core
│   ├── config/               # API config, feature flags
│   ├── extensions/           # Extension methods (e.g., l10n on BuildContext)
│   ├── models/               # Shared data models, Result type
│   ├── repositories/         # Data access (course_repository, score_repository)
│   ├── services/             # Core services — HTTP, Hive, Prefs, SecureStorage, Time
│   └── utils/                # Utilities — logger, request cache, platform_utils, animations
├── features/                 # Feature modules
│   ├── basic/                # Shared models/services (School, SchoolApi)
│   ├── education/            # Education features — courses, scores, login, auth
│   └── system/               # System features — notifications, updates, sharing
├── l10n/                     # ARB localization files (zh, en, ja, ko, fr, de, ru)
├── platform/                 # Platform-specific UI and services
│   ├── android/              # Android background services
│   ├── ios/                  # iOS background services
│   ├── macos/                # macOS sidebar and window shell
│   ├── mobile/               # Mobile bottom navigation
│   ├── tablet/               # Tablet NavigationRail layout
│   └── windows/              # Windows Fluent sidebar
├── routes/                   # GoRouter configuration
├── state/                    # Riverpod providers and freezed state classes
├── ui/                       # UI layer
│   ├── components/           # Reusable widgets
│   ├── pages/                # Page widgets (one per route)
│   └── theme/                # ClubTheme (light/dark), color scheme
├── main.dart                 # Entry point, platform init, provider bootstrap
└── main_app.dart             # Platform-adaptive app shell with navigation
```

### HTTP Layer

`BaseHttpClient` (`lib/core/services/base_http_client.dart`) wraps **Dio** with:
- Automatic retry via `RetryPolicy`
- Response caching via `CacheInterceptor`
- Configurable timeouts

Specialized clients extend this:
- `EduHttpClient` — authenticated requests to the education system API
- `BasicHttpClient` — unauthenticated API calls

### Logging

Use `AppLogger` (`lib/core/utils/app_logger.dart`) instead of `print()` or `debugPrint()`:

```dart
AppLogger.info('message');
AppLogger.error('message', error: e, stackTrace: s);
AppLogger.debug('debug only in debug mode');
```

A migration script exists at `scripts/replace_print_with_logger.dart`.

### Localization

Multi-language support via ARB files in `lib/l10n/`. Supported locales: zh, zh_Hant, en, ja, ko, fr, de, ru.

Access localized strings:
```dart
context.l10n.home          // Extension from localization_extensions.dart
AppLocaleService.localeOf(settingsStore.localeCode)  // Get current Locale
```

### Platform Detection

```dart
import 'package:ios_club_app/core/utils/platform_utils.dart';

PlatformUtils.isWindows / isMacOS / isAndroid / isIOS / isDesktop / isWeb / isMobile
PlatformUtils.getDesktopFontFamily(customFont)  // Desktop font handling
```

### Data Persistence

- **SharedPreferences** via `PrefsService` (`lib/core/services/prefs_service.dart`) with keys in `lib/state/prefs_keys.dart`
- **Hive** via `HiveManager` for structured local storage
- **FlutterSecureStorage** via `SecureStorageService` for sensitive data (credentials)

### Code Generation

Generated files (`.freezed.dart`, `.g.dart`) are committed. After modifying models or state classes, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Packages requiring code gen: `freezed`, `json_serializable`, `hive_generator`.

### Scripts

- `scripts/check_coverage.sh` — Run tests and verify 80% coverage threshold
- `scripts/clean_unused_imports.dart` — Batch-remove unused imports from specified files
- `scripts/replace_print_with_logger.dart` — Replace `print`/`debugPrint` calls with `AppLogger`

## Environment Configuration

```env
# UPDATE_CHANNEL options: gitee (default) | appstore
UPDATE_CHANNEL=gitee
```

- `gitee` — Check for updates from Gitee releases
- `appstore` — Disable update checking (for App Store builds)

Pass at build time: `--dart-define=UPDATE_CHANNEL=appstore`

## Widget Development

### Android Widgets
Provider: `android/app/src/main/kotlin/com/luckyfishisdashen/ios_club_app/TodayCoursesWidgetProvider.kt`
Update from Flutter: `await HomeWidget.updateWidget()`

### iOS Widgets
iOS widget extension in `ios/` directory with SwiftUI implementation.

## Key Conventions

### Import Order
1. Dart SDK (`dart:*`)
2. Flutter SDK (`package:flutter/*`)
3. Third-party packages
4. Local imports (`package:ios_club_app/*`)

Use relative imports only within the same module.

### Naming
- Classes/Enums: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `lowerCamelCase`
- Private members: prefix with `_`

### Error Handling
Return safe defaults rather than null. Use `AppLogger.error()` for diagnostics:
```dart
try {
  final result = await service.fetchData();
  return result ?? defaultValue;
} catch (e) {
  AppLogger.error('fetchData failed', error: e);
  return defaultValue;
}
```

### Testing
- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration tests: `test/integration/`
- Performance tests: `test/performance/`
- Test naming: `should_X_when_Y`
- Minimum coverage: 80%

## Git Repository

Primary repository: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile.git

## License

MIT License
