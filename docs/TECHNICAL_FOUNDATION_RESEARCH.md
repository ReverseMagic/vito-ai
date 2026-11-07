# Flutter Foundation and Dependency Compatibility Research

**Research date:** 2026-11-08  
**Status:** Evidence-based candidate baseline; final pins require a real project resolution and platform build.  
**Scope:** iOS and Android phone application only.

## 1. Findings

### Flutter and Dart

- Flutter's stable release line is 3.47. The Flutter repository's stable hotfix tracker records Flutter **3.47.9**, released 2026-10-29, with Dart **3.13.7** already current at that release.
- Flutter 3.50 is listed in the official release schedule for November 2026, but the official release notes and current stable tracker consulted for this research still identify 3.47 as the latest stable release. Do not adopt a beta/pre-release simply because the next stable window is near.
- Candidate SDK baseline: **Flutter 3.47.9 / Dart 3.13.7**. Pin the Flutter SDK exactly when the app is scaffolded; the Dart SDK is bundled with Flutter and should not be installed/pinned independently for the app build.

Sources:
- Flutter stable hotfix tracker: https://github.com/flutter/flutter/issues/195427
- Flutter stable changelog: https://github.com/flutter/flutter/blob/master/CHANGELOG.md
- Flutter official release notes: https://docs.flutter.dev/release/release-notes
- Flutter SDK archive and release schedule: https://docs.flutter.dev/install/archive

### Riverpod

- Latest stable package observed: `flutter_riverpod 3.5.0`, released 2026-11-06; minimum Dart SDK shown by pub.dev is 3.12.
- Previous stable `3.4.3` is also available and was released 2026-09-04.
- Riverpod supports a non-code-generation workflow using explicit provider declarations and handwritten `Notifier`/`AsyncNotifier` classes.
- Riverpod 3.5.0's changelog records a migration of Material imports to `package:material_ui/material_ui.dart` and a new dependency on `material_ui`. This is a relevant ecosystem change to verify during scaffold/build, not something to ignore.

Candidate:
- Use `flutter_riverpod` with handwritten providers only.
- Do not add `riverpod_generator`, `riverpod_annotation`, `build_runner`, or generated provider files.
- Prefer `Provider` for immutable dependencies, `NotifierProvider` for synchronous feature state, and `AsyncNotifierProvider` for asynchronous feature state when those abstractions fit. Do not create a Notifier for trivial derived values.
- Decide between 3.5.0 and 3.4.3 after running dependency resolution and focused provider tests with the pinned Flutter SDK. 3.5.0 is the latest stable but only two days old at research time; its compatibility and migration behavior must be exercised before adopting it.

Sources:
- https://pub.dev/packages/flutter_riverpod/versions
- https://pub.dev/packages/flutter_riverpod/changelog
- https://riverpod.dev/docs/concepts/about_code_generation

### GoRouter

- Latest stable observed: `go_router 18.1.3`, published by the Flutter team.
- The 18.0.0 changelog sets minimum support to Flutter 3.44 / Dart 3.12, so it is compatible by declared minimum with the candidate Flutter 3.47.9 / Dart 3.13.7 baseline.
- GoRouter supports deep links, nested routes, redirects, multiple navigators through `ShellRoute`, and `StatefulShellRoute` for persistent independent branch navigation.
- Its package page describes the package as feature-complete, with primary focus on bug fixes and stability. Treat it as a stable dependency, not as a rapidly evolving feature platform.
- Version 18.x migrated to the standalone `material_ui` and `cupertino_ui` packages.

Candidate:
- Use `go_router` directly, with handwritten `GoRoute` definitions and explicit route parsing/validation.
- Do not add `go_router_builder`, route annotations, or generated route files.
- Use `StatefulShellRoute` only if the approved information architecture needs independent retained navigation stacks per primary tab. Otherwise prefer a simpler route tree or `ShellRoute`.
- Keep redirects deterministic and based on app/session state; avoid async work in widgets and avoid redirect loops.
- Define navigation destinations and route paths centrally. Parse identifiers and query parameters at the route boundary; invalid/missing values must fail into a deliberate not-found/recovery state.
- Centralize route page transitions and reduced-motion behavior; do not set unrelated transition values route by route.

Sources:
- https://pub.dev/packages/go_router
- https://pub.dev/packages/go_router/changelog
- https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md

## 2. Important Flutter framework ecosystem change

Flutter 3.44 froze contributions to Material and Cupertino libraries inside the core SDK and introduced standalone `material_ui` and `cupertino_ui` packages. Flutter documents a migration path using `dart fix --apply --code=migrate_design_widgets`; formal deprecation of the in-framework design libraries is scheduled for a future stable release.

This creates a foundation decision that must be made consciously:
- New app UI should evaluate the standalone packages as the forward path.
- Verify the exact widgets, localization delegates, theming, accessibility, and third-party package interoperability needed by this product.
- Do not run an automated import migration blindly; review every changed import and test both platforms.
- Record the chosen UI import strategy and package versions in the architecture decision log after a successful build.

Source: https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui

## 3. Localization without code generation

The no-codegen constraint rules out the usual generated localization class from ARB files. It does not rule out Flutter's localization runtime or locale-aware formatting.

Candidate approach:
- Use Flutter SDK `flutter_localizations` delegates for framework widgets and locale behavior.
- Implement a small handwritten `AppLocalizations` value object and `LocalizationsDelegate`, with explicit English and Arabic resources.
- Keep translation keys and placeholders in parity with automated tests.
- Use `intl` directly for locale-aware date, number, plural, and bidi formatting where needed; do not use message extraction or code generation.
- Use `Locale` and `Directionality` consistently; do not manually reverse the entire widget tree.
- Keep language preference separate from device locale so users can explicitly choose Arabic or English.
- Verify mixed Arabic/Latin text, numbers, units, punctuation, dates, and text-field caret behavior on devices.

Package evidence:
- `intl 0.20.3` is current stable observed and requires Dart 3.9 or later.
- The Flutter localization guide explains supported locales, localization delegates, and text direction; the project will implement resources manually due to the explicit no-codegen rule.

Sources:
- https://docs.flutter.dev/ui/internationalization
- https://pub.dev/packages/intl/versions

## 4. Static analysis and tests

Candidate baseline:
- Use Flutter SDK `flutter_test` for unit and widget tests.
- Use Flutter SDK `integration_test` for critical device journeys.
- Use `flutter_lints 6.0.0` as a dev dependency; pub.dev lists minimum Dart 3.8.
- Prefer small handwritten fakes for feature boundaries initially. Add mocking libraries only when test complexity demonstrates a need.
- Do not introduce code-generation-based mocks or fixtures.
- Run format, analyze, unit/widget tests, and integration tests in CI on the exact pinned SDK.
- Add Android and iOS build jobs once native project files and signing/build environment are established.

Sources:
- https://docs.flutter.dev/testing
- https://docs.flutter.dev/testing/integration-tests
- https://pub.dev/packages/flutter_lints
- https://pub.dev/packages/flutter_lints/versions

## 5. Proposed dependency baseline (not yet committed to pubspec)

| Package / SDK | Candidate | Purpose | Status |
|---|---|---|---|
| Flutter SDK | 3.47.9 stable | Framework/toolchain | Recommended exact pin; build not yet run |
| Dart SDK | 3.13.7 (bundled) | Language/runtime | Comes with candidate Flutter SDK |
| flutter_riverpod | 3.5.0 or 3.4.3 | State/dependency management | Latest stable observed; choose after resolution and tests |
| go_router | 18.1.3 | Declarative navigation | Declared SDK minimum compatible |
| intl | 0.20.3 | Locale-aware formatting | Candidate; use only if needed directly |
| flutter_lints | 6.0.0 | Static analysis rules | Candidate dev dependency |
| flutter_localizations | Flutter SDK | Framework localization delegates | Use, but no generated app strings |
| flutter_test | Flutter SDK | Unit/widget testing | Use |
| integration_test | Flutter SDK | Device journey testing | Use |

This is deliberately a short baseline. No persistence, networking, database, analytics, AI, image, barcode, or backend packages are selected yet because the relevant product/service decisions are still open.

## 6. Architecture constraints for the initial Flutter foundation

- One app composition root owns initialization, global providers, theme, localization, and router construction.
- Feature-first boundaries remain the organizing principle; do not pre-create every future feature.
- Feature state belongs to its feature. Shared providers are limited to app-wide concerns such as theme, locale, and authenticated session after those exist.
- Use Riverpod providers as the dependency composition mechanism; avoid service locators and hidden global mutable state.
- UI widgets must not directly call network clients, database SDKs, or platform channels.
- Route definitions stay at the app boundary. Features expose screens/route builders through explicit interfaces rather than importing each other's internals.
- No domain/use-case/repository interface should exist unless it represents a meaningful rule or replaceable boundary.
- Keep platform-specific behavior behind a narrow boundary only when actual iOS/Android divergence exists.
- Add a design-system foundation before feature screens: semantic color roles, typography, spacing, shapes, component states, and motion tokens.
- Use the design system's semantic motion tokens for route transitions and microinteractions; include reduced-motion behavior.

## 7. Decisions that remain open

1. Whether to adopt `flutter_riverpod 3.5.0` immediately or start with 3.4.3 for a more conservative baseline.
2. Whether app widgets should import standalone `material_ui` / `cupertino_ui` packages or remain on Flutter core imports during the transition. This must be tested, not guessed.
3. Whether the approved primary navigation needs retained independent tab stacks (`StatefulShellRoute`) or a simpler shell.
4. Whether an FVM-style SDK pinning tool is accepted as a development tool, or the repository pins the SDK through CI and documented setup only.
5. Exact supported minimum iOS/Android versions, which affect plugin choices and native project configuration.

## 8. Verification still required before treating this baseline as final

- Install/use Flutter 3.47.9 stable and capture `flutter --version` and `flutter doctor -v`.
- Scaffold a minimal phone-only Flutter project and resolve dependencies.
- Run `flutter pub get`, `flutter analyze`, and `flutter test`.
- Build Android debug and release variants.
- Build iOS simulator and archive/release configuration on macOS.
- Verify Riverpod provider lifecycle and tests with the selected version.
- Verify GoRouter deep links, nested navigation, back behavior, and restoration.
- Verify manual localization delegate, Arabic RTL, and locale-aware formatting.
- Verify reduced-motion behavior for both Android animation removal and iOS Reduce Motion.
- Record all actual outputs and any failures; do not mark the SDK baseline verified until these checks pass.
