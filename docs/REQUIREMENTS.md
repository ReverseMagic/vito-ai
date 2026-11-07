# Product Requirements and Acceptance

## Product intent

Help people understand and manage daily nutrition with minimal effort and reliable, transparent food logging. The product should feel calm, clear, responsive, and trustworthy—not like a dense spreadsheet or a gamified dashboard.

The product should reduce:
- Time and steps needed to log a meal.
- Repeated typing and searching.
- Mental arithmetic and macro calculation.
- Uncertainty about what has been logged and what remains.
- Navigation effort and decision fatigue.

It must not reduce friction by hiding uncertainty, silently inventing nutrition facts, or making irreversible changes without user control.

## Fixed scope

- iOS and Android phones only.
- English and Arabic, with LTR and RTL.
- System, light, and dark appearance.
- Flutter, feature-first architecture, Riverpod manual providers, GoRouter.
- No Freezed and no code generation packages.

## Candidate MVP capabilities

These are product candidates, not claims of implementation. Final prioritization and detailed behavior require product discovery.

1. Onboarding and profile: locale, units, basic profile, goals, dietary preferences, and consent.
2. Nutrition targets: daily calorie target and macro targets with transparent calculation/editing.
3. Food catalog and search: food details, serving sizes, portions, source attribution, and confidence/quality indicators.
4. Food diary: meal grouping, add/edit/delete, date navigation, daily totals, undo/recovery where practical.
5. Fast logging: recent foods, favorites, custom foods, barcode scanning, and meal reuse where data quality supports them.
6. Progress: weight entries, trends, history, and understandable summaries.
7. Account and settings: theme, language, units, privacy, data export/deletion, and session management.
8. AI-assisted logging/coaching: only after a safe backend, user disclosure/consent, evaluation, cost controls, and editable estimates are in place.

## Explicit non-goals until approved

- Web, desktop, and tablet-first product experiences.
- Medical diagnosis, treatment, or clinical decision support.
- Claims that AI food recognition produces exact nutrition values.
- Social network, public profiles, or community feed.
- Wearable/health-platform integrations.
- Subscriptions, payments, or monetization.
- Push notifications and behavioral marketing.
- Any specific backend, AI model, food database, analytics vendor, or cloud provider before a recorded decision.

## UX principles

- One obvious primary action per context.
- Show the user's current state and next useful action without requiring interpretation.
- Prefer defaults that are transparent, editable, and reversible.
- Progressive disclosure: show essential information first; advanced detail on demand.
- Keep the daily diary scannable and avoid competing cards, charts, badges, and decorative elements.
- Preserve user-entered data across interruptions and recover from errors.
- Never punish users for missing a day or use shame-based language.
- Explain estimates and data sources; make correction easy.
- Use familiar iOS/Android interaction behavior where platform conventions differ.

## Requirement traceability and acceptance checklist

Statuses begin as **Not Started**. A requirement is Passed only when the stated acceptance condition has been observed and evidence is recorded. Code existing is not evidence of behavior.

| ID | Requirement | Acceptance condition | Verification evidence | Status |
|---|---|---|---|---|
| UX-001 | Low-friction daily logging | A representative user can add a known food, choose portion, and see updated totals without duplicate entry or hidden steps; task time/steps are measured in usability testing | Usability task protocol, recordings/notes, automated journey | Not Started |
| UX-002 | Clear information hierarchy | In usability testing, users can identify remaining calories, logged meals, and primary add-food action without explanation | Moderated/unmoderated usability findings | Not Started |
| UX-003 | Predictable navigation | Primary destinations, detail flows, back behavior, and restoration behave consistently on iOS and Android | Navigation/integration tests and device checks | Not Started |
| UX-004 | Recovery and feedback | Loading, empty, error, offline, validation, success, disabled, and destructive states are designed and tested for each applicable journey | State matrix and widget/integration tests | Not Started |
| UX-005 | User control | Food estimates and calculated targets can be inspected and edited; destructive changes are confirmed and recoverable where practical | Feature tests and usability review | Not Started |
| DS-001 | Central design system | Shared visual values are defined once as semantic tokens; components consume tokens; no unexplained per-screen styling constants | Static review, token/component tests | Not Started |
| DS-002 | Component consistency | Shared controls have documented anatomy, variants, states, semantics, and interaction behavior | Component catalog and widget/golden tests | Not Started |
| LOC-001 | English/Arabic parity | Every user-facing string is localized; translation keys match; plural/select behavior is correct | Localization parity test | Not Started |
| LOC-002 | RTL/LTR correctness | Critical screens pass in Arabic RTL and English LTR, including mixed-direction text, input caret, punctuation, numbers, and navigation | Widget tests and manual device review | Not Started |
| LOC-003 | Text scaling | Critical screens remain usable at large system text settings without clipping essential actions/content | Accessibility tests and device review | Not Started |
| A11Y-001 | Assistive technology | Critical journeys expose correct labels, roles, values, states, reading order, and focus behavior | Semantics tests; VoiceOver/TalkBack review | Not Started |
| A11Y-002 | Accessible interaction | Touch targets, contrast, keyboard/focus, reduced motion, and non-gesture alternatives meet documented platform guidance | Automated checks and device review | Not Started |
| THEME-001 | Theme coverage | System/light/dark themes cover all shared components and critical screens without unreadable or inconsistent states | Theme widget/golden matrix | Not Started |
| PERF-001 | Responsive interactions | No avoidable synchronous heavy work on UI thread; scrolling and transitions meet a defined frame-time budget on representative devices in profile/release mode | Flutter DevTools timeline and device measurements | Not Started |
| PERF-002 | Startup and memory | Startup, memory, image/cache use, and long-session behavior have measured budgets before release | Profile/release benchmarks | Not Started |
| DATA-001 | Nutrition correctness | Serving conversion, energy/macronutrient totals, rounding, units, and date boundaries are specified and covered by deterministic tests | Domain/unit tests and reviewed fixtures | Not Started |
| DATA-002 | Data integrity | Duplicate submissions, retries, offline edits, account switching, and concurrent updates do not corrupt or cross-contaminate user data | Repository/backend integration tests | Not Started |
| SEC-001 | Authentication and authorization | Every private operation is authorized server-side; negative cross-user access tests fail closed | Backend security tests | Not Started |
| SEC-002 | Secrets and privacy | No provider secrets in app/repository; logs exclude sensitive nutrition/profile data; data collection and retention are documented | Secret scan, code review, data-flow review | Not Started |
| SEC-003 | Account lifecycle | Sign-out, expiry, recovery, account switching, export, and deletion behavior are specified and tested | Auth/backend integration tests | Not Started |
| AI-001 | Safe AI estimates | AI outputs are schema-validated, labeled as estimates, editable, and never silently committed as verified facts | Evaluation set, contract tests, UX review | Not Started |
| AI-002 | AI privacy and cost | Data sent to models is minimized and disclosed; quotas, rate limits, abuse controls, timeout, retry, and cost limits are enforced server-side | Security review, load/abuse tests, cost telemetry | Not Started |
| QA-001 | Regression coverage | Critical journeys have deterministic automated tests and defects receive regression tests | CI test reports | Not Started |
| PLAT-001 | iOS/Android behavior | Permission, keyboard, safe-area, system back, navigation, lifecycle, and install/upgrade behavior are checked on both platforms | Device/simulator checklist and evidence | Not Started |
| REL-001 | Release readiness | Reproducible pinned toolchain, CI checks, environment separation, signing configuration, privacy disclosures, and store compliance are reviewed | Release checklist and CI artifacts | Not Started |

## Definition of product acceptance

A release candidate cannot be accepted while any critical requirement for nutrition correctness, data integrity, privacy/security, authorization, localization, accessibility, or platform behavior is Failed or Not Verified. Remaining non-critical gaps must be documented, severity-assessed, and explicitly accepted by the product owner.

Performance claims require profile/release-mode measurements on representative physical devices. Debug-mode impressions and widget tests do not prove smoothness.

## Product questions still requiring decisions

- Final product name, brand identity, and voice.
- Target age range and market-specific legal/privacy requirements.
- Whether onboarding asks for height, weight, age, sex, activity level, and which of these are optional.
- Goal types and target-calculation methodology.
- Food data providers, licensing, coverage, and provenance.
- Backend provider and data residency requirements.
- AI provider, model, consent, retention, and budget.
- Analytics approach and consent policy.
- Supported minimum iOS and Android versions.
- Monetization and subscription scope.
