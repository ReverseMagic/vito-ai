# Project

## Identity

- Repository: `ReverseMagic/vito-ai`
- Working title: Vito AI (not yet confirmed as final public brand)
- Product: mobile nutrition and calorie tracking
- Platforms: iOS and Android phones only
- Locales: English and Arabic
- Appearance: system, light, and dark

## Fixed constraints

- Flutter + Dart.
- Feature-first architecture.
- Riverpod with manual providers only.
- GoRouter without route code generation.
- No Freezed and no code generation packages.
- No web, desktop, or tablet-first product.
- First-party centralized design system and consistent interaction patterns.

## Selected platforms and services

- Supabase is the selected backend platform. No Supabase project is connected yet.
- Gemini is the selected AI provider. All Gemini requests must pass through authenticated Supabase Edge Functions.
- The Gemini API key must be stored only as a server-side Edge Function secret.
- Food catalog provider, auth methods, Supabase region, storage policy, and backup/restore configuration remain undecided.

## Implemented application slice

- Flutter app entry point, app composition, GoRouter tab shell, manual Riverpod providers, and centralized monochrome light/dark themes.
- English and Arabic ARB localization with Flutter's built-in localization generation.
- Today, Diary, Activity, and Profile tabs.
- Manual food entry for calories and optional protein/carbohydrate/fat values.
- Explicit null handling for unknown macro values.
- Food entries and theme/locale preferences are currently in-memory only and reset when the process ends.
- Automated Flutter CI workflow is configured for format, analyze, and tests.

## Toolchain and dependencies

- FVM SDK pin: Flutter 3.47.9 (stable).
- Dart constraint: >=3.12.0 <4.0.0; Dart is supplied by the pinned Flutter SDK.
- `flutter_riverpod: ^3.5.0`.
- `go_router: ^18.1.3`.
- `flutter_lints: ^6.0.0`.
- Exact resolved dependency versions will be recorded in `pubspec.lock` after CI/package resolution.

## Not implemented / blocked

- Native Android/iOS runner projects are not checked in yet; README documents the one-time Flutter platform generation command.
- Durable SQLite persistence and offline synchronization.
- Supabase authentication, schema migrations, and RLS policies.
- Gemini-backed AI capture, barcode/catalog search, label scanning, camera/gallery, and voice capture.
- Activity/workout entry and device health integrations.
- Persistent preferences, calorie goals, and nutrient target setup.
- No Supabase project, production backend, Edge Function, or provider credentials are configured.

## Architecture and product documentation

- Product requirements: `docs/REQUIREMENTS.md` and `docs/TRACKING_AND_CAPTURE_REQUIREMENTS.md`.
- Proposed persistence model: `docs/DATA_MODEL.md` (not approved or migrated).
- Proposed AI/backend contracts: `docs/EDGE_FUNCTION_CONTRACTS.md` (not implemented or deployed).
- Architecture decisions: `docs/DECISIONS.md`.
- Project setup and current state: repository `README.md`.

## Release status

Development only. No release build, device verification, accessibility audit, performance profile, store submission, or production deployment has been completed. Do not treat this slice as a production nutrition record.
