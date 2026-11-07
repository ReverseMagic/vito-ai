# Repository Engineering Rules

These instructions apply to every change in this repository. Product requirements are in `docs/REQUIREMENTS.md`; project state in `docs/PROJECT.md`; durable decisions in `docs/DECISIONS.md`; known issues in `docs/ISSUES.md`.

## Product constraints

- Build a phone-first Flutter application for iOS and Android only.
- Support Arabic and English from the beginning. RTL is a first-class layout direction, not a late translation task.
- Support system, light, and dark appearance.
- Use feature-first organization, Riverpod manual providers, and GoRouter.
- Do not use Freezed, build_runner, generated Riverpod providers, generated route code, or other code generation packages. Flutter's built-in localization generation is also excluded unless the product owner explicitly changes this constraint.
- Never add web, desktop, or tablet-first targets or product surfaces.

## Engineering principles

1. Inspect the existing implementation and current official documentation before changing APIs, dependencies, platform behavior, or security-sensitive code.
2. Do not guess versions. Pin an exact stable Flutter SDK and compatible Dart/package versions after verification.
3. Prefer the smallest design that meets current requirements. No speculative abstractions, generic frameworks, service locators, or layers that merely forward calls.
4. Keep one source of truth for design tokens, typography, localization, app configuration, route contracts, and shared behavior.
5. Keep feature implementation inside its owning feature. Shared code must have a demonstrated second consumer and a stable contract.
6. Presentation must not own persistence, network calls, database mapping, or business rules.
7. Parse and validate untrusted input at boundaries. Use typed immutable models and explicit mapping; do not leak backend DTOs into UI.
8. Apply SOLID where it improves cohesion, testability, or change isolation. Do not create interfaces or abstractions solely to satisfy a principle.
9. Never put secrets, service-role credentials, AI provider keys, personal data, or production credentials in source control, client bundles, logs, or example configuration.
10. Never claim a command, test, build, device check, or feature passed without observed evidence.

## Design system and UX

- Build and use a first-party design system. Semantic tokens are the only source for color, typography, spacing, sizing, shape, elevation, borders, and motion.
- Components must consume semantic tokens; features must not hardcode visual values or reimplement shared patterns.
- Define component states and behavior: default, pressed, focused, disabled, loading, error, and selected where applicable.
- Establish patterns for navigation, forms, validation, dialogs, sheets, snackbars, empty states, loading, errors, offline behavior, destructive actions, and confirmation.
- Keep the primary task obvious. Reduce choices, repeated entry, memory burden, unnecessary steps, and context switching.
- Prefer sensible defaults, progressive disclosure, search/recent/favorites, autofill, and automation only when they are accurate and reversible.
- Motion must communicate state or continuity, be interruptible, respect reduced-motion settings, and never delay essential actions.
- Respect platform conventions on iOS and Android instead of forcing identical interaction details.
- Accessibility is part of implementation: semantics, focus order, screen readers, dynamic text, contrast, touch targets, and non-gesture alternatives.

## Localization and directionality

- No user-facing hardcoded strings.
- Keep English and Arabic translation keys in parity.
- Use directional layout APIs and logical start/end alignment; avoid physical left/right assumptions.
- Verify mixed Arabic/Latin content, numbers, punctuation, URLs, phone numbers, dates, units, and text input/caret behavior.
- Never mirror meaningful media, charts, or time axes blindly.
- Test long translations and large system text sizes in both directions.

## Architecture boundaries

- Organize by feature, with presentation and data responsibilities separated.
- Widgets render state and dispatch user intent; they do not call backend SDKs or storage directly.
- Providers compose dependencies and expose feature state. Repositories own data access, mapping, caching, and persistence boundaries.
- Put cross-feature composition and route registration at the app boundary. Avoid feature-to-feature internal imports.
- Use a domain layer only for meaningful business rules; do not create pass-through use cases.
- Centralize app failures and safe user-facing error mapping. Never show raw backend/provider exception text.

## Data, privacy, and security

- Treat food logs, weight, goals, and nutrition information as sensitive personal data.
- Collect only data needed for a clearly described product purpose.
- Define ownership, authorization, retention, export, and deletion behavior before shipping cloud persistence.
- Enforce authorization on the server/database, not merely in the client.
- If Supabase is selected, use least-privilege grants and tested row-level security policies for every user-owned table.
- AI requests must minimize data, disclose relevant processing, validate outputs, control quotas/costs, and fail safely. Provider keys remain server-side.
- AI-generated nutrition estimates must be clearly presented as estimates and editable by the user. Never represent them as clinical advice.

## Quality workflow

For each meaningful task:
1. State intended behavior, edge cases, platform differences, and acceptance criteria.
2. Inspect relevant code and current official docs.
3. Implement the smallest coherent change.
4. Add or update unit/provider/widget/integration/backend tests appropriate to risk.
5. Run formatting, static analysis, and relevant tests on the pinned toolchain.
6. Review security, accessibility, Arabic/RTL, dark/light, and failure states where applicable.
7. Report changed files, observed verification, failures, and unverified work.

Critical user journeys, data integrity, privacy, authorization, localization, accessibility, and release configuration are blocking quality gates. Do not mark work complete when a critical gate is unverified or failing.

## Change management

- Use focused branches and pull requests for substantive changes.
- Review external contributions; do not merge untrusted code automatically.
- Keep commits focused and descriptive.
- Update the relevant source-of-truth document when a durable product or architecture decision changes.
- Add regression tests for defects. Fix root causes rather than suppressing symptoms.
