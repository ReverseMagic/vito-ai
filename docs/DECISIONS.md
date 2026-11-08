# Decisions and Assumptions

This file is the source of truth for durable product and architecture decisions. Add dated entries with context, decision, and consequences. Do not silently turn assumptions into requirements.

## Confirmed constraints

### DEC-001 — Mobile-only product
- Date: 2026-11-07
- Context: Product is intended for phone users on Apple's and Google's mobile platforms.
- Decision: Build iOS and Android phone experiences only. No web or desktop product. Do not optimize the product for tablets.
- Consequences: Platform-specific behavior and verification are required on both mobile operating systems.

### DEC-002 — Arabic and English from the foundation
- Date: 2026-11-07
- Context: Both languages are core product requirements.
- Decision: Support English/LTR and Arabic/RTL from the first shared UI and navigation implementation.
- Consequences: Localization, directional layout, mixed-direction text, input, formatting, and accessibility are architectural acceptance requirements.

### DEC-003 — Theme modes
- Date: 2026-11-07
- Context: Users require both light and dark appearance.
- Decision: Support system, light, and dark modes through centralized semantic theme tokens.
- Consequences: Every shared component and critical screen must be reviewed in all supported themes.

### DEC-004 — Flutter architecture stack
- Date: 2026-11-07
- Context: Product owner selected Flutter, feature-first organization, Riverpod, and GoRouter.
- Decision: Use Flutter/Dart, feature-first architecture, Riverpod manual providers, and GoRouter.
- Consequences: Do not add competing state management or navigation systems. Exact versions and APIs must be verified before implementation.

### DEC-005 — No code generation packages or Freezed
- Date: 2026-11-07
- Context: Product owner explicitly disallows code generation and Freezed.
- Decision: Use handwritten Dart models/providers/routes and avoid code generation packages and generated route/provider code. Flutter's built-in ARB localization generation is permitted; it does not add a third-party code-generation package.
- Consequences: Parsing, immutability, equality, and route contracts must be implemented deliberately and tested.

### DEC-006 — Centralized product design system
- Date: 2026-11-07
- Context: Product owner requires consistent senior-level design and engineering standards.
- Decision: Create one first-party design system with semantic tokens, typography, components, patterns, motion, and accessibility contracts. Feature screens consume it rather than inventing local styles.
- Consequences: Shared visual and interaction changes are reviewed centrally; tokens and component contracts require tests.

### DEC-007 — Supabase backend
- Date: 2026-11-08
- Decision: Supabase is the selected backend platform.
- Intended capabilities: Auth, Postgres, Storage only where needed, and Edge Functions for server-side integrations.
- Required controls: RLS for user-owned data, least-privilege grants, authenticated/authorized functions, version-controlled migrations, separate environments.
- Still open: sign-in methods, schema, storage retention, hosting region, backup/restore objectives, and detailed policies.
- Status: platform confirmed; implementation pending.

### DEC-008 — Gemini through Supabase Edge Functions
- Date: 2026-11-08
- Decision: Gemini is the selected AI provider. Every Gemini request from Flutter must pass through an authenticated Supabase Edge Function. Store the Gemini API credential as a Supabase Edge Function secret and read it only server-side.
- Prohibited: Gemini key in Dart, assets, build config, Git, client responses, logs, or analytics.
- Functions must authenticate/authorize callers, validate/bound inputs, enforce rate/quota/cost controls, validate model output, and return typed drafts.
- AI output is a proposal, not verified nutrition data; user review/edit/confirmation is mandatory before saving.
- Still open: model/version, fallback, prompt/schema versioning, image/audio support, retention, evaluation, usage limits, and budget.
- Status: provider and security boundary confirmed; implementation pending.

### DEC-009 — Expanded tracking and capture
- Date: 2026-11-08
- Decision: Required capabilities include calories, carbs, protein, fat, sugar, fiber, sodium, water, steps, burned calories, running, weightlifting, and free-text/manual workout entry.
- Decision: Food capture must support photo scan, barcode, food-label scan, gallery, voice, manual entry, and food database search.
- These are required product capabilities; this does not mean every method ships in the first release. Prioritization and external integrations remain open.
- Detailed contract: `docs/TRACKING_AND_CAPTURE_REQUIREMENTS.md`.

### DEC-010 — Flutter toolchain and package baseline
- Date: 2026-11-08
- Context: The first Flutter app code requires a reproducible SDK and verified router/state dependencies.
- Decision: Pin Flutter stable 3.47.9 with FVM. Start with `flutter_riverpod 3.5.0` and `go_router 18.1.3`; keep providers and route declarations handwritten. Use Flutter's built-in ARB localization generation.
- Evidence: Flutter release changelog and pub.dev package metadata were checked on 2026-11-08.
- Consequences: CI uses the same Flutter version. Dependency resolution and compile/test results must be verified in CI before the code is considered buildable. Commit the resolved `pubspec.lock` when generated by a verified toolchain.

### DEC-011 — First vertical slice uses transient food-log state
- Date: 2026-11-08
- Context: The app shell and manual food-entry journey can be implemented before the database and offline-sync contracts are finalized.
- Decision: The first app slice stores food entries and appearance/language preferences in process memory only. It must visibly disclose that entries reset when the process ends.
- Consequences: This is development-only behavior, not a production nutrition record. Durable SQLite persistence, offline behavior, and account sync remain required follow-up work before user data is relied upon.

## Open decisions (not approved)

- Food catalog providers, licensing, regional coverage, and data quality.
- Product brand, logo, accent strategy, typography, and tone of voice.
- Minimum supported iOS/Android versions.
- Analytics and crash-reporting providers and privacy controls.
- Account sign-in methods and recovery behavior.
- Health platform integrations, notifications, monetization, and subscriptions.
- Exact nutrition-goal calculation and supported dietary workflows.
- Offline logging and synchronization/conflict behavior.
- Capture media transport, retention, and AI model/evaluation/cost limits.

## Assumptions policy

An assumption is not a decision. Every assumption must have an owner, a validation method, and a resolution date before it can become a shipped product behavior. If a missing decision affects safety, privacy, data integrity, cost, or irreversible behavior, stop and ask the product owner.
