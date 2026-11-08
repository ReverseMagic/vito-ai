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

This first implementation slice contains Flutter application code and automated Dart checks. Native Android/iOS runner projects are not checked in yet; generate them once from the repository root:

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
- Manual food entry for calories, carbohydrates, protein, fat, total sugars, fiber, and sodium.
- Quick-add water intake in 250 ml increments.
- Food and water entries persist in a local SQLite database on the device.
- Unknown nutrient values remain SQL NULL and are shown as unknown, not zero.
- Today summaries include calories, macros, other nutrients, and water intake.
- English/Arabic localization; Flutter localization supplies RTL direction.
- System/light/dark appearance selection.
- SQLite repositories and Riverpod async state.

## Not implemented yet

- Persistent appearance/language preferences and calorie/nutrient goal setup.
- Supabase authentication, account sync, schema migrations, and RLS policies.
- Gemini-backed AI capture, barcode/catalog search, label scanning, camera/gallery, and voice capture.
- Activity/workout entry and device health integrations.
- Backup/export/deletion flows.

**Development limitation:** food and water logs are stored locally on this device only. They are not synced or backed up to an account. Native Android/iOS runner projects must be generated using the command above before launching on a phone.

The product/engineering decision history and detailed requirements are maintained in [docs/](docs/).
