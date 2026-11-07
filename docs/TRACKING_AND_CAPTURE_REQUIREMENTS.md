# Tracking, Activity, Food Capture, and AI Backend Requirements

**Status:** Product-owner-confirmed capability scope; sequencing and detailed implementation contracts remain open.  
**Recorded:** 2026-11-08

## Nutrition and hydration
Track calories, carbohydrates, protein, total fat, total sugars, dietary fiber, sodium, and water. Canonical units, rounding, source, serving basis, and missing-data semantics must be explicit. Do not conflate sodium with salt or total sugars with added sugars. Unknown values are not zero.

## Activity and body weight
Track steps, burned/activity calories, running, weightlifting/strength, other workouts, free-text manual workout descriptions, and dated body-weight records. Manual workout logging must work without a wearable. Minimum workout fields are type, date, and description; duration, time, distance, sets/reps/load, effort, and calorie estimate are optional. Distinguish user-entered, imported, estimated, and calculated values. Do not silently add exercise calories to the food budget.

## Required food capture methods
1. Camera meal photo scan.
2. Barcode scan and product lookup.
3. Food/nutrition-label scan and nutrient extraction.
4. Gallery photo selection.
5. Voice description/transcription.
6. Manual food entry.
7. Food database search.

Every method needs cancel, retry, correction, and manual fallback. AI/OCR/voice output is an editable draft and requires explicit user confirmation before saving. Show source, serving basis, completeness, and uncertainty. Label values must distinguish per-serving from per-100g/ml. Arabic/English search and validated aliases are required. Permissions are requested at point of need.

## Supabase backend
Supabase is the confirmed backend platform. Intended services are Auth, Postgres, RLS, Storage only when retention is justified, and Edge Functions for server-side integrations. Use version-controlled migrations, least-privilege grants, user-scoped RLS, and separate environments. Auth methods, schema, hosting region, backup objectives, and retention remain open.

The Flutter app may contain the Supabase project URL and publishable key. The publishable key is not a substitute for RLS. Never ship Supabase secret/service-role keys in the mobile app.

## Gemini request and secret flow

```text
Flutter app with authenticated Supabase session
  -> Supabase Edge Function
       -> authenticate and authorize caller
       -> validate request, file type, size, and payload
       -> enforce rate, quota, and cost limits
       -> read GEMINI_API_KEY from Edge Function secret environment
       -> call Gemini
       -> validate and normalize model output
       -> return typed editable draft
  -> user reviews and edits
  -> explicit confirmation
  -> save confirmed record through authorized Supabase data path
```

The Gemini key exists only in Supabase Edge Function secrets. It must never appear in Flutter source/assets/build configuration, Git, client responses, logs, or analytics. Local development uses an ignored local secrets file; production uses Supabase Dashboard or CLI secret management. Do not retain raw photos/audio by default. Define consent, retention, deletion, and vendor data handling before launch. The Gemini model, fallback policy, prompts, output schema, evaluation set, and budgets remain open.

## Still undecided
- Gemini model/version, fallback, voice/audio model, retention, evaluation, and usage budget.
- Supabase Auth methods, data schema, storage, region, backup/restore.
- Food catalog provider/licensing/regional coverage and custom-food rules.
- Barcode/label OCR approach and voice transcription approach.
- HealthKit/Health Connect integrations versus manual-only activity capture for initial release.
- Burned-calorie source and whether it affects remaining calories.
- Nutrition target methodology, units, timezone policy, and retention.
- Release prioritization for the seven capture methods.

## Release gates
- Deterministic nutrient and unit tests; unknown values not zero; sodium/salt and sugars/added sugars distinct.
- Label serving basis correct; manual workouts and weight history CRUD tested.
- Provenance visible; AI/OCR/voice require confirmation.
- RLS isolation tested with separate accounts.
- Gemini key absent from source, mobile artifacts, logs, and responses.
- Edge Function auth, authorization, validation, rate/quota controls, timeout, and failure handling tested.
- Camera/microphone/gallery denial and recovery paths tested on both platforms.


## Official implementation references checked (2026-11-08)

- Supabase Flutter client: https://supabase.com/docs/reference/dart/introduction
- Supabase Flutter quickstart and production RLS/key guidance: https://supabase.com/docs/guides/getting-started/quickstarts/flutter
- Supabase Edge Functions overview and server-side AI integration use cases: https://supabase.com/docs/guides/functions
- Supabase Edge Function secret management and runtime environment variables: https://supabase.com/docs/guides/functions/secrets
- Supabase Edge Function authentication patterns: https://supabase.com/docs/guides/functions/auth
- Google Gemini API key security and backend proxy guidance: https://ai.google.dev/gemini-api/docs/api-key

These references support the proposed server-side secret boundary and Supabase integration. They do not constitute a completed deployment, configured project, or verified implementation.
