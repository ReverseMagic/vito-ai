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
- GoRouter without code generation.
- No Freezed and no code generation packages.
- No web, desktop, or tablet-first product.
- First-party centralized design system and consistent interaction patterns.

## Current status

- Repository is public and initially empty at project start.
- Initial product/engineering governance is being established.
- Candidate toolchain research recommends Flutter 3.47.9 stable / Dart 3.13.7; this has not yet been installed, pinned, or build-verified. Riverpod and GoRouter package candidates and no-codegen localization constraints are documented in `docs/TECHNICAL_FOUNDATION_RESEARCH.md`.
- Backend provider, AI provider/model, food-data providers, supported OS minimums, and final brand identity remain unselected.
- No mobile feature, backend, migration, build, or test is currently claimed as implemented.

## Planned structure

The final structure will be confirmed in an architecture decision before scaffolding. Expected boundaries:

```
lib/
  app/                 # bootstrap, composition, router, app-level providers
  core/                # app-agnostic infrastructure and shared technical concerns
  design_system/       # semantic tokens, themes, typography, components, motion
  l10n/                # English and Arabic localization resources
  features/
    <feature>/
      models/           # feature-owned immutable app models
      data/             # repositories, data sources, mapping
      domain/           # only when meaningful business rules justify it
      presentation/     # screens, widgets, feature state/providers
test/
integration_test/
docs/
```

Do not create empty directories or speculative layers merely to match this sketch.

## Environments and services

No backend project or production service is connected yet. Development, staging, and production configuration must be separated before external services or deployments are introduced. Secrets belong in secret managers, never in Git.

## Release status

Not started. Store listing, bundle identifiers, signing, privacy disclosures, supported OS versions, and release pipelines require explicit decisions and verification.
