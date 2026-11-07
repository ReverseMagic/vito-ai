# Edge Function API contracts

**Status:** Proposed contract design. No Edge Function has been implemented or deployed. Exact Gemini model, limits, retention, and provider details remain open.

## 1. Security and execution boundary

All Gemini-backed operations originate from the authenticated Flutter app and pass through Supabase Edge Functions. The app must never call Gemini directly.

Request flow:

1. Flutter obtains the current Supabase access token through the authenticated session.
2. Flutter invokes the named Edge Function with the access token and request payload.
3. The function validates the caller and obtains the authenticated user identity.
4. The function validates request shape, size, MIME type, and allowed operation.
5. The function enforces per-user rate limits, concurrency limits, and cost/quota controls.
6. The function calls Gemini using a server-side secret.
7. The function validates the model response against a strict versioned schema and normalizes units/fields.
8. The function returns a typed, editable draft. It does not write a diary entry.
9. Flutter presents the result for correction and explicit confirmation.
10. A separate authenticated persistence operation saves the user's confirmed entry.

The Gemini API key must exist only in Supabase Edge Function secrets. It must not appear in Flutter source, assets, build-time defines, mobile binaries, Git history, client responses, analytics, crash reports, or logs. Supabase service-role credentials must likewise remain server-side. The Supabase publishable key is not a substitute for authorization; database access remains protected by RLS.

## 2. Contract conventions

- JSON over HTTPS.
- Version every request/response schema (initial proposal: `schema_version: 1`).
- Use stable machine-readable error codes.
- Include a request/correlation ID in responses and server logs; never log secrets or raw media.
- Enforce request byte limits before expensive model calls.
- Reject unsupported MIME types and malformed payloads.
- Do not trust client-provided user IDs; derive identity from the validated access token.
- Do not accept model output as trusted SQL, executable code, or authorization instructions.
- Normalize numeric outputs to documented units; represent unknown values as `null`.
- Keep model/provider metadata internal or return only safe, non-sensitive diagnostic metadata.
- Return drafts only. No capture endpoint may silently create diary, water, workout, or profile records.

## 3. Common response envelope

Success:

```json
{
  "schema_version": 1,
  "request_id": "opaque-correlation-id",
  "status": "draft",
  "draft": {}
}
```

Error:

```json
{
  "schema_version": 1,
  "request_id": "opaque-correlation-id",
  "error": {
    "code": "INVALID_INPUT",
    "message_key": "capture.error.invalidInput",
    "retryable": false
  }
}
```

The user-facing message is localized by the app using `message_key`; do not expose raw provider errors, prompts, stack traces, internal URLs, or secrets. Error codes below are proposed and should be centralized in a shared contract before implementation.

## 4. Meal photo analysis

Proposed function: `analyze-meal-photo`

Input fields:
- `schema_version`: required integer.
- `image`: one image payload using a transport selected during implementation (multipart upload or short-lived storage reference; do not base64 large images by default).
- `locale`: `en` or `ar`.
- `context`: optional user-provided description, cuisine hint, or correction context.
- `idempotency_key`: client-generated opaque key for safe retries.

Output draft:
- `capture_type`: `meal_photo`.
- `items[]`: editable candidate food items.
- Per item: `display_name`, optional `brand`, `quantity`, `quantity_unit`, optional `estimated_grams`, `nutrients`, `confidence`, `assumptions[]`.
- Nutrients use stable codes and explicit units; missing values are `null`.
- `serving_basis`: explicit basis for nutrient values.
- `warnings[]`: ambiguity, occlusion, portion uncertainty, or incomplete nutrient coverage.
- `requires_confirmation`: always `true`.

The function must not claim exact ingredient identity or precise portion weight from an image when the evidence does not support it. It must surface ambiguity and allow the user to replace, remove, split, or add items. A photo result is an estimate, not a measurement.

## 5. Nutrition label extraction

Proposed function: `extract-nutrition-label`

Input:
- image payload / approved short-lived media reference.
- locale.
- optional user-selected serving context.
- idempotency key.

Output:
- product name and brand if legible.
- serving size and serving unit.
- separate `per_serving` and `per_100g_or_100ml` nutrient objects when present on the label.
- nutrient values with explicit units and nullable unknowns.
- extracted text confidence / warnings.
- `requires_confirmation: true`.

Never infer absent label values as zero. Preserve the label's basis exactly. Do not interchange sodium and salt. OCR extraction must be visibly correctable before saving.

## 6. Voice food logging

Proposed function: `parse-voice-food-log`

Input:
- audio payload or transcription text, depending on the transcription architecture selected later.
- locale.
- optional parsing context.
- idempotency key.

Output:
- transcript (only if policy permits returning it).
- parsed food items, quantities, units, and nutrient lookup needs.
- unresolved phrases/questions.
- warnings for uncertain quantities or food names.
- `requires_confirmation: true`.

Voice transcription and semantic parsing may be separate providers/operations. Provider choice, supported audio formats, maximum duration, language/dialect coverage, and raw-audio retention are undecided. The UI must support correction and manual entry if recording or transcription fails.

## 7. Barcode lookup

Barcode lookup is not automatically a Gemini task. Proposed function boundary if the selected catalog provider requires a backend proxy:

Input:
- barcode string with validated length/format.
- locale.
- optional region hint.

Output:
- match status: found / not_found / ambiguous.
- product identity and attribution/source.
- serving basis and available nutrient fields.
- completeness metadata.

The external catalog provider and licensing are not selected. Do not fabricate product results or fill missing nutrition with model guesses without a separate, explicit user-visible estimate flow.

## 8. Food search

Food search should use a selected food catalog/search provider and return paginated results with source attribution, localized names/aliases, serving basis, and nutrient completeness. Search provider and ranking strategy remain undecided. AI should not be used as an unmarked replacement for a catalog lookup.

## 9. Draft persistence and confirmation

Preferred default: capture results are transient and held as editable client-side drafts until confirmed. If server-side draft persistence becomes necessary for multi-step workflows, it must:
- bind every draft to the authenticated user;
- store no raw image/audio by default;
- have a short, explicit expiry;
- prevent cross-user reads/writes through RLS or narrowly scoped server access;
- support deletion and cleanup;
- avoid using draft data for training or secondary purposes without a separate lawful, explicit basis and product consent;
- never count toward nutrition totals before confirmed persistence.

Saving a confirmed diary entry should use a separate database operation with transaction semantics. If an AI draft is corrected by the user, corrected values are user-entered; untouched estimates retain AI-estimated provenance.

## 10. Validation, limits, and abuse controls

Before launch, define and enforce:
- maximum request size and accepted media MIME types;
- image dimension / audio duration limits;
- request timeout and provider timeout;
- maximum model output tokens / response size;
- per-user rate limits and concurrent request limits;
- daily/monthly usage quotas and hard cost ceilings;
- abuse detection and account-level suspension behavior;
- retry policy with bounded exponential backoff and jitter;
- idempotency semantics for client retries;
- circuit-breaker/fallback behavior if Gemini is unavailable;
- alerting for spend, error rates, latency, and quota exhaustion.

Do not set arbitrary production limits in code before product, cost, and provider decisions are reviewed. Start with conservative configurable limits and validate against expected usage and provider terms.

## 11. Error taxonomy

Initial proposed codes:

| Code | Meaning | Retryable |
|---|---|---|
| `UNAUTHENTICATED` | Missing, invalid, or expired session | After re-authentication |
| `FORBIDDEN` | Caller is not allowed to perform this operation | No |
| `INVALID_INPUT` | Request shape or field validation failed | No; correct input |
| `UNSUPPORTED_MEDIA` | MIME type or media format is unsupported | No; choose supported media |
| `PAYLOAD_TOO_LARGE` | Input exceeds configured limit | No; reduce input |
| `RATE_LIMITED` | Caller exceeded an operation limit | Yes, after server-provided delay |
| `QUOTA_EXCEEDED` | Usage/cost allowance exhausted | No until quota changes |
| `PROVIDER_UNAVAILABLE` | Upstream model/catalog provider unavailable | Yes, bounded |
| `PROVIDER_TIMEOUT` | Upstream provider timed out | Yes, bounded |
| `INVALID_PROVIDER_OUTPUT` | Model output failed schema/semantic validation | Possibly; do not return malformed data |
| `INTERNAL_ERROR` | Unexpected server failure | Possibly; safe generic message |

Do not leak provider stack traces or raw model content in error messages. Retry only when the operation is safe and idempotent.

## 12. Observability and privacy

Log request ID, operation, authenticated user reference (pseudonymous where feasible), timing, outcome code, token/usage metadata when available, and cost estimate. Do not log access tokens, Gemini keys, raw image/audio, full transcripts, or sensitive food/health details unless an approved observability design explicitly requires a minimal subset.

Define retention and deletion for logs separately from product data. Restrict dashboard/log access. Establish incident response and secret rotation procedures before production.

## 13. Open decisions blocking implementation

1. Gemini model ID/version, supported modalities, and fallback model.
2. Whether photo and label images are passed directly to Gemini or preprocessed with a separate OCR pipeline.
3. Voice transcription provider and whether transcription is separate from Gemini parsing.
4. Media transport and maximum payload limits.
5. Function names and whether operations are combined or split.
6. Exact JSON schemas and schema-validation implementation.
7. Rate limits, quotas, spend ceilings, and user-facing usage policy.
8. Retry/idempotency storage design.
9. Draft persistence decision and retention period.
10. Prompt versioning, evaluation dataset, quality thresholds, and regression testing.
11. Food catalog provider and whether barcode/search are proxied through Edge Functions.
12. Whether AI requests may use contextual profile/preferences and, if so, the minimum necessary fields.

## 14. Release gates

- [ ] Gemini key exists only in Edge Function secrets and has a documented rotation path.
- [ ] No provider secret or service-role key appears in client artifacts or Git history.
- [ ] Auth is verified server-side; caller identity is never accepted from request body.
- [ ] Input size, media type, timeout, quota, and rate controls are enforced.
- [ ] Output is schema-validated and semantically bounded before returning.
- [ ] Unknown nutrients remain null; units and serving basis are explicit.
- [ ] AI results are editable drafts and require explicit confirmation.
- [ ] No endpoint writes a food log as a side effect of analysis.
- [ ] Logs exclude secrets and raw media.
- [ ] Privacy, retention, deletion, and consent behavior is documented.
- [ ] Provider failures and malformed outputs have tested safe fallbacks.
- [ ] Cost, latency, and quality have measured acceptance thresholds.
