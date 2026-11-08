# Vito AI

A bilingual nutrition companion for Android and iOS.

## Requirements

- Flutter stable 3.47.9 managed with FVM
- Dart bundled with that Flutter SDK
- Android Studio and Android SDK for Android builds
- Xcode on macOS for iOS builds

## Setup

```sh
fvm install
fvm flutter pub get
```

This first implementation slice contains Flutter application code and automated Dart checks. Native Android/iOS runner projects are not included yet; generate them once from the repository root:

```sh
fvm flutter create --platforms=android,ios --project-name=vito_ai --org=com.reversemagic .
```

Then run on a connected device or simulator:

```sh
fvm flutter devices
fvm flutter run
```

## Checks

```sh
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

## Current implementation

- Four-tab mobile shell: Today, Diary, Activity, Profile.
- Manual food entry with calories and optional macro values.
- Unknown macro values remain unknown instead of being stored as zero.
- English/Arabic localization; Flutter localization supplies RTL direction.
- System/light/dark appearance selection.
- Session-only food state for this first vertical slice.

## Not implemented yet

- Durable SQLite persistence and offline synchronization.
- Supabase authentication, schema migrations, and RLS policies.
- Gemini-backed AI capture, barcode/catalog search, label scanning, camera/gallery, and voice capture.
- Activity/workout entry and device health integrations.
- Persistent preferences, calorie goals, and nutrient target setup.

**Development limitation:** food entries and preferences currently reset when the app process ends. Do not use this slice as a production nutrition record.

The product/engineering decision history and detailed requirements are maintained in [docs/](docs/).
