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

### DEC-005 — No code generation or Freezed
- Date: 2026-11-07
- Context: Product owner explicitly disallows code generation and Freezed.
- Decision: Use handwritten Dart models/providers/routes and avoid code generation packages and generated route/provider code.
- Consequences: Parsing, immutability, equality, and route contracts must be implemented deliberately and tested. Any proposed exception requires explicit approval.

### DEC-006 — Centralized product design system
- Date: 2026-11-07
- Context: Product owner requires consistent senior-level design and engineering standards.
- Decision: Create one first-party design system with semantic tokens, typography, components, patterns, motion, and accessibility contracts. Feature screens consume it rather than inventing local styles.
- Consequences: Shared visual and interaction changes are reviewed centrally; tokens and component contracts require tests.

## Open decisions (not approved)

- Backend provider and deployment topology.
- AI provider/model, data handling, retention, evaluation, and cost limits.
- Food catalog providers, licensing, regional coverage, and data quality.
- Product brand, logo, accent strategy, typography, and tone of voice.
- Minimum supported iOS/Android versions.
- Analytics and crash-reporting providers and privacy controls.
- Account sign-in methods and recovery behavior.
- Health platform integrations, notifications, monetization, and subscriptions.
- Exact nutrition-goal calculation and supported dietary workflows.

## Assumptions policy

An assumption is not a decision. Every assumption must have an owner, a validation method, and a resolution date before it can become a shipped product behavior. If a missing decision affects safety, privacy, data integrity, cost, or irreversible behavior, stop and ask the product owner.


## Proposed technical baseline (not approved or build-verified)

### PROP-001 — Candidate Flutter toolchain and packages
- Research date: 2026-11-08
- Evidence: Flutter stable hotfix tracker identifies Flutter 3.47.9 with Dart 3.13.7; current pub.dev package metadata lists flutter_riverpod 3.5.0 (Dart >=3.12) and go_router 18.1.3 (Flutter >=3.44 / Dart >=3.12). intl 0.20.3 and flutter_lints 6.0.0 are also compatible by their published minimum Dart versions.
- Proposal: Use Flutter 3.47.9 stable / Dart 3.13.7 as the candidate SDK baseline; use handwritten Riverpod providers and GoRouter routes; no generator packages.
- Unresolved: Riverpod 3.5.0 has only just been released; verify it against the app before adoption. Review the Flutter 3.44 standalone Material/Cupertino package migration. Run dependency resolution, tests, and Android/iOS builds before pinning the versions in project files.
- Status: Proposed — not approved, not implemented, not build-verified.
- Research: `docs/TECHNICAL_FOUNDATION_RESEARCH.md`.

### PROP-002 — Manual localization implementation
- Research date: 2026-11-08
- Proposal: Use Flutter localization runtime delegates with handwritten English/Arabic resources and parity tests; use intl for formatting only where required. Do not use gen_l10n output or any localization code generator.
- Status: Proposed — not yet implemented.
- Research: `docs/TECHNICAL_FOUNDATION_RESEARCH.md`.
