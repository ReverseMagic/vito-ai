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

## Selected platforms and services

- Supabase is the selected backend platform. No Supabase project is connected yet.
- Gemini is the selected AI provider. All Gemini requests must pass through authenticated Supabase Edge Functions.
- The Gemini API key must be stored only as a server-side Edge Function secret.
- No production service, database migration, or Edge Function is currently deployed.
- Food catalog provider, auth methods, Supabase region, storage policy, and backup/restore configuration remain undecided.

## Current documentation status

- Product requirements and acceptance criteria are documented in `docs/REQUIREMENTS.md` and `docs/TRACKING_AND_CAPTURE_REQUIREMENTS.md`.
- A proposed persistence model is documented in `docs/DATA_MODEL.md`; it is not yet approved or migrated.
- Proposed AI/backend contracts are documented in `docs/EDGE_FUNCTION_CONTRACTS.md`; they are not implemented or deployed.
- Architecture and product decisions are tracked in `docs/DECISIONS.md`.
- Flutter SDK version, package versions, and supported OS minimums still require current compatibility research and approval.

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

Use separate development, staging, and production configuration. Secrets belong in secret managers, never in Git. Supabase publishable keys may be present in the mobile client only with RLS and least-privilege policies; service-role credentials and Gemini credentials must remain server-side.

## Release status

Not started. Store listing, bundle identifiers, signing, privacy disclosures, supported OS versions, and release pipelines require explicit decisions and verification. No mobile feature, backend, migration, build, or test is currently claimed as implemented.
