# Data model and persistence design

**Status:** Proposed design for review. This document is not an applied database migration and does not authorize deployment.

## 1. Design constraints

- Supabase Postgres is the system of record for authenticated, cross-device account data.
- The mobile client may cache data locally for responsive UI and offline-tolerant capture, but local cache is not authoritative after server reconciliation.
- Every user-owned row is scoped to one authenticated user. Authorization is enforced by Postgres Row Level Security (RLS), not by client-side filters.
- Store the facts needed to reproduce a diary entry as logged. Do not silently rewrite historical nutrition when a catalog record changes.
- Keep source, measurement basis, uncertainty, and provenance explicit.
- Missing nutrient data is `NULL` / unknown, never silently coerced to zero.
- Use UTC instants for event timestamps and an explicit IANA timezone for user-local diary-day boundaries.
- Avoid storing sensitive raw media unless a reviewed, explicit product requirement justifies it. Default capture processing is transient; see retention decisions below.
- Schema names and table boundaries are proposals. Confirm them during schema review before writing migrations.

## 2. Core entities and relationships

### Account and preferences

| Entity | Purpose | Important fields |
|---|---|---|
| `profiles` | App-owned profile keyed to Supabase Auth user | `user_id` (PK/FK to auth user), display name (optional), created/updated timestamps |
| `user_preferences` | User-specific product preferences | `user_id` (PK), locale, preferred unit system, IANA timezone, theme preference, week-start preference, updated timestamp |
| `nutrition_goals` | Versioned user targets | id, user_id, effective-from local date, optional effective-to date, calorie target, optional macro/micronutrient targets, created timestamp |

Do not duplicate credentials, password hashes, or auth-provider tokens in app tables. Auth lifecycle belongs to Supabase Auth. Locale and timezone are preferences, not reliable substitutes for device settings at the instant of an event.

### Food catalog references and snapshots

| Entity | Purpose | Important fields |
|---|---|---|
| `food_catalog_items` | Optional normalized cache/reference to an external or curated catalog item | id, provider key, provider item ID, canonical name, language/locale, brand (optional), barcode (optional), source metadata, fetched timestamp |
| `food_catalog_nutrients` | Nutrient values associated with a catalog item and a stated basis | catalog item ID, basis quantity/unit, nutrient code, nullable amount, source |
| `food_diary_entries` | A logged food event | id, user_id, local diary date, consumed-at instant (optional), meal slot (optional), note, entry status, source kind, created/updated timestamps |
| `food_entry_items` | One or more foods within a diary event | id, diary entry ID, optional catalog item reference, display-name snapshot, quantity, quantity unit, grams (nullable), serving label snapshot, source/provenance |
| `food_entry_nutrients` | Immutable nutrient snapshot for each logged item | food entry item ID, nutrient code, nullable amount, unit, basis quantity, completeness/source metadata |

A diary entry may contain multiple items (e.g. a meal photo draft resolved into several ingredients). Each saved item must preserve the displayed food name, serving basis, quantity, and nutrient snapshot used at save time. Catalog references are optional: users must be able to create a manual food without a provider ID.

Do not assume a single universal serving unit. Preserve the entered amount and unit, and store a normalized mass/volume conversion only when the conversion is known and defensible. Do not infer grams from an arbitrary serving label.

### Nutrient vocabulary

Use stable machine codes with display labels localized separately. Initial supported codes:

- energy_kcal
- carbohydrate_g
- protein_g
- fat_g
- sugar_total_g
- fiber_g
- sodium_mg
- water_ml

Keep total sugars distinct from added sugars. Salt is not interchangeable with sodium. If a future catalog supplies added sugars, saturated fat, cholesterol, or other nutrients, add them as separately defined nutrients rather than overloading an existing code.

Nutrient values are non-negative decimal quantities unless a future domain review documents an exception. Choose database precision only after reviewing source precision and conversion requirements. Do not use binary floating point for persisted nutrient arithmetic. API and Dart representations must preserve decimal meaning and rounding rules.

### Hydration

| Entity | Purpose | Important fields |
|---|---|---|
| `water_logs` | A water-intake event | id, user_id, consumed-at instant, local diary date, volume_ml, optional source/container label, created timestamp |

Water is recorded as volume with a clear unit. Do not silently count beverages as water unless a documented product rule defines the behavior.

### Activity and workouts

| Entity | Purpose | Important fields |
|---|---|---|
| `activity_daily_summaries` | Daily step and energy observations from an identified source | id, user_id, local diary date, steps (nullable), active_energy_kcal (nullable), total_energy_kcal (nullable only if later defined), source, observed interval, imported timestamp |
| `workouts` | User workout record, manual or imported | id, user_id, workout type, title/description, started-at/ended-at instants (optional), duration_seconds (optional), distance_m (optional), energy_kcal (nullable), energy provenance, source, created/updated timestamps |
| `workout_sets` | Optional structured strength-training detail | id, workout ID, exercise name, set order, reps (optional), load and unit (optional), effort (optional), notes |

Workout types should include running, strength/weightlifting, and other/manual description. A free-text description is always supported. Structured sets are optional; do not force a strength workout into a running-style duration/distance model.

Steps and energy observations must retain their source and observation interval. Do not add workout calories to the food budget or change a calorie target based on activity until a separately approved product rule defines exactly how this works.

### Body measurements

Body-weight history appeared as a candidate in earlier product planning but was not explicitly confirmed in the user's expanded capability list. Keep it **out of the committed MVP schema** until product-owner confirmation. If approved later, model dated measurements with unit, provenance, and correction/deletion behavior; do not treat weight as a required profile field.

### AI and capture drafts

| Entity | Purpose | Important fields |
|---|---|---|
| `capture_drafts` | Optional server-side record of a pending analysis result | id, user_id, capture type, normalized structured draft, schema version, model/provider metadata, status, created/expiry timestamps |
| `capture_feedback` | Optional quality feedback after user correction | id, user_id, draft ID, feedback category, corrected-field indicators, created timestamp |

The default should be **not to persist original photos, gallery images, audio, or extracted label images**. Process transiently and delete temporary objects promptly. If a future design requires durable media storage, it needs explicit consent, storage access policies, retention period, deletion/export behavior, and a documented security review before implementation.

A capture draft is not a diary record. It must remain editable and must not affect totals until the user explicitly confirms saving. Expired or abandoned drafts must not become food logs.

## 3. Provenance and data quality

Use a constrained provenance vocabulary consistently across food, activity, and measurements:

- `user_entered`: directly supplied or edited by the user.
- `catalog`: imported from a named food-data source.
- `device_imported`: imported from an authorized device/platform source.
- `ai_estimated`: estimated by an AI model.
- `calculated`: derived by a documented deterministic calculation.

Keep source identity and timestamps separately where needed. Provenance describes where a value came from; it does not certify accuracy. An AI estimate must never be labeled measured. A user correction changes provenance for the corrected field to user-entered while retaining relevant origin metadata for audit/debugging without retaining raw media.

For every nutrient set, retain completeness information so the UI can distinguish:
- known value,
- unknown/missing value,
- not applicable (only where domain semantics justify it).

Do not calculate a full meal total and present it as complete if one or more constituent values are unknown. Any displayed aggregate must disclose partial data or follow a documented exclusion rule.

## 4. Diary date and timezone rules

- Persist event instants in UTC.
- Persist the IANA timezone used to assign the event to a local diary date, or preserve the resolved local date at event creation.
- A diary date is a calendar date in the user's selected diary timezone, not a UTC date.
- Define behavior for travel and timezone changes before implementing day summaries: historical entries should not unexpectedly move between dates after a preference change.
- Backdated manual entries use the selected local date and optional local time.
- Day-boundary aggregation must be tested around daylight-saving transitions even if initial target users are in regions without DST.

## 5. Integrity, deletion, and idempotency

- Use primary keys and foreign keys for ownership relationships.
- Use database constraints for positive quantities, valid ranges, allowed enum/code values, and mutually consistent timestamps.
- Use unique constraints for provider identity where appropriate (provider + provider item ID); do not assume barcode uniqueness globally without catalog-specific validation.
- Client-generated operation IDs may be used for safe retry/idempotency, but the exact offline-sync strategy is still open.
- Use transactions when saving a diary entry and its items/nutrient snapshots so partial meals cannot be committed accidentally.
- Define whether user deletion cascades through all app-owned rows and any storage objects. The intended user-facing behavior is account deletion with associated app data deletion, subject to documented legal/operational retention requirements.
- Export and deletion flows must cover logs, drafts, feedback, caches, and stored media if any is later introduced.

## 6. RLS and authorization policy matrix

RLS must be enabled on every user-owned table. The baseline policy is that an authenticated user can select, insert, update, and delete only rows whose `user_id` equals `auth.uid()`. For child tables without a direct `user_id`, authorize through the owning parent row and verify the parent belongs to `auth.uid()`.

| Data group | Read | Insert | Update | Delete |
|---|---|---|---|---|
| Profile/preferences | Own user only | Own user only | Own user only | Controlled account lifecycle |
| Goals | Own user only | Own user only | Own user only | Own user only |
| Food diary and item snapshots | Own user only | Own user only | Own user only | Own user only |
| Water logs | Own user only | Own user only | Own user only | Own user only |
| Activity/workouts/sets | Own user only | Own user only | Own user only | Own user only |
| Capture drafts/feedback | Own user only | Server-authorized or own user according to endpoint design | Restricted; draft state transitions validated server-side | Own user / expiry cleanup |

Catalog data may be shared/readable according to provider licensing and product policy. It must not expose private user records. Service-role credentials must never be shipped to the client. Edge Functions should use the caller's authenticated identity and least-privilege access; any privileged server-side operation must be narrowly scoped and audited.

RLS policies must be tested with at least two distinct users, including direct API attempts against another user's IDs. UI-level hiding is not a security test.

## 7. Indexing and query patterns

Expected access patterns:
- Fetch a user's diary entries for a local date, ordered by consumed time/creation time.
- Fetch food items and nutrient snapshots for selected diary entries.
- Fetch water logs for a local date.
- Fetch steps/activity summaries and workouts for a local date or date range.
- Fetch effective nutrition goals for a date.
- Search shared catalog records by provider identity, barcode, and localized searchable names.

Candidate indexes should be validated with real query plans and representative data before production. Likely candidates include user_id + diary_date, user_id + event timestamp, parent foreign keys, and catalog provider identity/barcode. Avoid speculative indexes on every column.

## 8. Derived totals and caching

Daily totals are derived from saved diary snapshots and water/activity events. The source of truth remains the event rows; cached aggregates may be introduced only with an explicit invalidation/rebuild strategy. Do not store a daily calorie total as the only representation of food history.

Define rounding once at the presentation boundary. Sum stored decimal values at adequate precision, then round for display. Do not repeatedly round individual items before aggregation unless the source's declared precision requires it.

## 9. Decisions still required before migrations

1. Confirm exact MVP profile/preferences fields and whether body-weight tracking is in scope.
2. Confirm meal taxonomy and whether meal entries support arbitrary named meals in addition to standard meal slots.
3. Confirm offline logging and sync/conflict behavior.
4. Confirm account deletion/export requirements and operational retention constraints.
5. Confirm timezone-change and travel behavior.
6. Confirm food catalog provider, licensing, regional coverage, and attribution.
7. Confirm whether capture drafts are stored server-side at all; default recommendation is transient processing and client-side editable draft state.
8. Confirm nutrition-goal types, effective-date rules, and whether users can set sugar/fiber/sodium/water targets.
9. Confirm how activity energy is displayed; no automatic calorie-budget adjustment is authorized.
10. Confirm whether imported device activity is MVP or deferred; HealthKit and Health Connect remain undecided.

## 10. Migration readiness checklist

- [ ] Product owner approves entities, fields, and scope.
- [ ] External food provider and licensing constraints are known.
- [ ] Decimal precision, unit conversions, and rounding rules are documented.
- [ ] Local-day/timezone behavior is specified.
- [ ] Offline/idempotency behavior is specified.
- [ ] RLS policies exist for every user-owned table.
- [ ] Cross-user isolation tests pass.
- [ ] Deletion/export/retention behavior is specified and tested.
- [ ] Schema migrations are reviewed and reproducible in local/staging environments.
- [ ] No service-role key or provider secret is present in mobile code or committed files.

## References

- [Supabase Flutter documentation](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase database documentation](https://supabase.com/docs/guides/database/overview)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
